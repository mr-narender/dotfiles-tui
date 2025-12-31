# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'

require_relative '../common'
require_relative 'hooks'
require_relative 'system'

module Bootstrap
  class Configurator
    FORMULAE = %w[
      aria2 bat bash bottom cmake coreutils duti fd ripgrep
      fzf gcc git jj git-lfs gnutls go gnupg
      pinentry-mac gpg2 mas mcfly neovim node
      oh-my-posh openjdk openssh openssl ouch procs lsd
      readline rsync ruby shellcheck shfmt
      ssh-copy-id tlrc watch wget zsh zsh-completions
    ].freeze

    FORMULAE_DISABLED = %w[rust].freeze

    MAS_APPS = [
      { name: '1Blocker', id: 1_365_531_024, enabled: true },
      { name: 'Bitwarden', id: 1_352_778_147, enabled: true },
      { name: 'Auto HD FPS for YouTube', id: 1_546_729_687, enabled: true },
      { name: 'Numbers', id: 409_203_825, enabled: true },
      { name: 'Pages', id: 409_201_541, enabled: true },
      { name: 'The Unarchiver', id: 425_424_353, enabled: true },
      { name: 'Save to Raindrop.io', id: 1_549_370_672, enabled: true },
      { name: 'Amphetamine', id: 937_984_704, enabled: true },
      { name: 'Velja', id: 1_607_635_845, enabled: true },
      { name: 'CotEditor', id: 1_024_640_650, enabled: true },
      { name: 'Super Agent for Safari', id: 1_568_262_835, enabled: true },
      { name: 'Sequel Ace', id: 1_518_036_000, enabled: false },
      { name: 'WireGuard', id: 1_451_685_025, enabled: false },
      { name: 'Poolsuite FM', id: 1_514_817_810, enabled: false },
      { name: 'AdGuard for Safari', id: 1_440_147_259, enabled: false },
      { name: 'Xcode', id: 497_799_835, enabled: true }
    ].freeze

    PRIORITY_HOOKS = %w[core cargo mos zsh starship lunarvim].freeze

    attr_reader :script_dir, :hooks_dir, :configs_dir, :core_dir, :dry_run
    attr_accessor :quiet

    def initialize(dry_run: false)
      @script_dir = ENV.fetch('SCRIPT_DIR', File.expand_path('../../..', __dir__))
      @hooks_dir = ENV.fetch('HOOKS_DIR', File.join(@script_dir, 'Hooks'))
      @configs_dir = ENV.fetch('CONFIGS_DIR', File.join(@script_dir, 'Configs'))
      @core_dir = ENV.fetch('CORE_DIR', File.join(@hooks_dir, 'core'))
      @prereq_marker = File.join(Dir.tmpdir, 'has_pre_requisite_ran')
      @user = ENV.fetch('USER', nil)
      @dry_run = dry_run
    end

    def pre_requisite
      if prerequisites_ran?
        Bootstrap::Display.info('Pre-requisite check completed.')
        return
      end

      ensure_sudo!
      add_to_sudoers
      install_cargo_toolchain
      ensure_homebrew_installed
      ensure_stow_installed
      setup_env_file
      run_priority_hooks
      mark_prerequisites_done
    end

    def install_brew_formulas
      apply_brew_environment
      Bootstrap::Display.header('Installing formulae')

      Bootstrap::Spinner.spin('Installing formulae...') do |spinner|
        FORMULAE.each do |formula|
          # Start task for this formula
          if Bootstrap::Display.tui
            Bootstrap::Display.tui.start_task(formula)
          end

          # Install the formula
          install_formula(formula, spinner)

          # Mark task as complete
          if Bootstrap::Display.tui
            success = formula_installed?(formula)
            Bootstrap::Display.tui.complete_task(success: success)
          end
        end
      end
      Bootstrap::Display.persist('All formulae installed', :success)
    end

    def install_brew_casks
      apply_brew_environment
      Bootstrap::Display.header('Installing casks')

      Bootstrap::Spinner.spin('Installing casks...') do |spinner|
        Dir.children(@hooks_dir).sort.each do |dir_name|
          next if dir_name.start_with?('.')
          next if PRIORITY_HOOKS.include?(dir_name)

          # Start task for this cask
          if Bootstrap::Display.tui
            Bootstrap::Display.tui.start_task(dir_name)
          end

          install_hook(dir_name, spinner)

          # Mark task as complete
          if Bootstrap::Display.tui
            Bootstrap::Display.tui.complete_task(success: true)
          end
        end
      end
      Bootstrap::Display.persist('All casks installed', :success)
    end

    def install_mas_apps
      mas = find_binary('mas', ['/opt/homebrew/bin/mas'])
      raise 'mas CLI is not installed. Exiting.' if mas.nil?

      Bootstrap::Display.header('Installing Mac App Store applications')
      Bootstrap::Display.info('Please login to the App Store if prompted.')

      MAS_APPS.each do |app|
        next unless app[:enabled]

        Bootstrap::Display.info("Installing #{app[:name]}")
        Bootstrap::System.run(%(#{mas} install #{app[:id]}), allow_failure: true, dry_run: @dry_run)
      end
    end

    def link_configs
      validate_directory(@configs_dir, 'Configs')
      validate_directory(@hooks_dir, 'Hooks')
      apply_brew_environment

      Bootstrap::Spinner.spin('Linking Configs...') do |spinner|
        Dir.children(@configs_dir).sort.each do |dir|
          next if dir.start_with?('.')

          dir_path = File.join(@configs_dir, dir)
          next unless File.directory?(dir_path)

          if package_linked?(dir)
            Bootstrap::Logger.log("Skipping #{dir} (already linked)")
            next
          end

          # Start task for this config
          if Bootstrap::Display.tui
            Bootstrap::Display.tui.start_task(dir)
          end

          spinner.update("Linking #{dir}...")
          self.quiet = true

          run_hook(dir, :pre)
          Bootstrap::Logger.log("Linking #{dir}")
          Bootstrap::System.run(%(stow --adopt --target="#{Dir.home}" --dir="#{@configs_dir}" "#{dir}"), dry_run: @dry_run, quiet: true)
          run_hook(dir, :post)

          self.quiet = false

          # Mark task as complete
          if Bootstrap::Display.tui
            Bootstrap::Display.tui.complete_task(success: true)
          end
        end
      end
      Bootstrap::Display.persist('All configs linked', :success)
    end

    def unlink_configs
      validate_directory(@configs_dir, 'Configs')

      Bootstrap::Spinner.spin('Unlinking Configs...') do |spinner|
        Dir.children(@configs_dir).sort.each do |dir|
          next if dir.start_with?('.')

          dir_path = File.join(@configs_dir, dir)
          next unless File.directory?(dir_path)

          spinner.update("Unlinking #{dir}...")
          Bootstrap::Logger.log("Unlinking #{dir}")
          Bootstrap::System.run(%(stow --target="#{Dir.home}" --dir="#{@configs_dir}" --delete "#{dir}"), allow_failure: true, dry_run: @dry_run, quiet: true)
        end
      end
      Bootstrap::Display.persist('All configs unlinked', :success)
    end

    def setup_uv
      return Bootstrap::Display.info('uv already installed') if Dir.exist?(File.join(Dir.home, '.local', 'bin', 'uv'))

      Bootstrap::Display.header('Installing Astral uv')
      Bootstrap::System.run('curl -LsSf https://astral.sh/uv/install.sh | bash -s', dry_run: @dry_run)
      Bootstrap::System.run("#{File.join(Dir.home, '.local', 'bin', 'uv')} python install --default --preview-features python-install-default", allow_failure: true, dry_run: @dry_run)
    end

    def setup_env_file
      env_source = File.join(@script_dir, '.env')
      env_dest = File.join(Dir.home, '.env')

      return unless File.exist?(env_source)

      if File.exist?(env_dest) && !File.symlink?(env_dest)
        Bootstrap::Display.warn("~/.env exists and is not a symlink. Skipping link.")
        return
      end

      # Check if it points to the right place
      if File.symlink?(env_dest) && File.readlink(env_dest) == env_source
        Bootstrap::Display.info("~/.env already linked.")
        return
      end

      Bootstrap::Display.header('Linking .env')
      Bootstrap::System.run("ln -sf #{env_source} #{env_dest}", dry_run: @dry_run)
    end

    def inject_secrets(secrets_path)
      return if secrets_path.nil? || secrets_path.empty?

      unless File.directory?(secrets_path)
        Bootstrap::Display.warn("Secrets directory not found at #{secrets_path}. Skipping injection.")
        return
      end

      Bootstrap::Display.header("Injecting secrets from #{secrets_path}")

      # Inject .env
      secrets_env = File.join(secrets_path, '.env')
      if File.exist?(secrets_env)
        Bootstrap::Display.info("Copying .env from #{secrets_env}...")
        Bootstrap::System.run("cp #{secrets_env} #{@script_dir}/.env", dry_run: @dry_run)
      end

      # Inject Configs
      secrets_configs = File.join(secrets_path, 'Configs')
      if File.directory?(secrets_configs)
        Bootstrap::Display.info("Copying Configs from #{secrets_configs}...")
        # We use cp_r with remove_destination: true to overwrite existing files/symlinks
        # But we need to be careful. We want to merge directories, not replace them entirely if possible.
        # FileUtils.cp_r merges directories.
        Bootstrap::System.run("cp -R #{secrets_configs}/. #{@configs_dir}/", dry_run: @dry_run)
      end

      # Inject Hooks
      secrets_hooks = File.join(secrets_path, 'Hooks')
      if File.directory?(secrets_hooks)
        Bootstrap::Display.info("Copying Hooks from #{secrets_hooks}...")
        # Use shell globbing to include hidden files
        # cp -R source/. dest/ usually works, but let's be explicit
        Bootstrap::System.run("cp -R #{secrets_hooks}/. #{@hooks_dir}/", dry_run: @dry_run)
      end
    end

    def setup_conda
      Bootstrap::Display.header('Configuring Conda environment')
      Bootstrap::System.run('conda init && source ~/.zshrc', dry_run: @dry_run)
      Bootstrap::System.run('conda create -n default python=3.9.4 --yes', dry_run: @dry_run)
      Bootstrap::System.run('conda config --set changeps1 False', dry_run: @dry_run)
    end

    def setup_rye
      path = File.join(Dir.home, '.rye', 'env')
      if Dir.exist?(path)
        Bootstrap::Display.info('rye already installed')
        return
      end

      Bootstrap::Display.header('Installing Astral rye')
      Bootstrap::System.run('curl -sSf https://rye.astral.sh/get | RYE_INSTALL_OPTION="--yes" bash', dry_run: @dry_run)
    end

    def install_rosetta
      Bootstrap::System.run('/usr/sbin/softwareupdate --install-rosetta --agree-to-license', allow_failure: true, dry_run: @dry_run)
    end

    def restart_launchpad
      Bootstrap::System.run('defaults write com.apple.dock ResetLaunchPad -bool true && sudo killall Dock', allow_failure: true, dry_run: @dry_run)
    end

    def change_default_shell
      zsh_path = find_binary('zsh')
      return Bootstrap::Display.warn('Zsh not found, skipping default shell change.') if zsh_path.nil?

      Bootstrap::System.run(%(echo "#{zsh_path}" | sudo tee -a /etc/shells), allow_failure: true, dry_run: @dry_run)
      Bootstrap::System.run("chsh -s #{zsh_path}", allow_failure: true, dry_run: @dry_run)
      Bootstrap::System.run("sudo chsh -s #{zsh_path}", allow_failure: true, dry_run: @dry_run)
    end

    def fix_insecure_dir_problems
      commands = [
        '[[ -e ~/.zcompdump* ]] && rm -f ~/.zcompdump*',
        '[[ -n $(command -v compinit) ]] && compinit',
        '[[ -n $(command -v compaudit) ]] && compaudit | xargs -n1 -r chmod g-w,o-w',
        '[[ -d /usr/local/share ]] && chmod go-w /usr/local/share || printf ""'
      ]

      commands.each { |cmd| Bootstrap::System.run(cmd, allow_failure: true, dry_run: @dry_run) }
    end

    def tweak_macOS_configuration
      commands = [
        'brew analytics off',
        'sudo spctl --master-disable',
        'defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false',
        '/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user',
        'defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false',
        'defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false',
        'defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true',
        'defaults write NSGlobalDomain AppleShowAllExtensions -bool true',
        'defaults write NSGlobalDomain KeyRepeat -int 0',
        'defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false',
        'defaults write com.apple.finder ShowStatusBar -bool true',
        'defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false',
        'defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true',
        'defaults write com.apple.frameworks.diskimages skip-verify -bool true',
        'defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true',
        'defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true',
        'defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false',
        'defaults write com.apple.terminal StringEncodings -array 4',
        'defaults write com.apple.Terminal "Default Window Settings" -string "Pro"',
        'defaults write com.apple.Terminal "Startup Window Settings" -string "Pro"',
        'chflags nohidden ~/Library',
        'sudo chflags nohidden /Volumes',
        'defaults write NSGlobalDomain KeyRepeat -int 2',
        'defaults write NSGlobalDomain InitialKeyRepeat -int 15',
        'defaults write -g WebAutomaticTextReplacementEnabled -bool true',
        'defaults write NSGlobalDomain AppleShowScrollBars -string "Always"',
        'defaults write com.apple.dock mru-spaces -bool false',
        'defaults write com.apple.dock autohide-time-modifier -int 0',
        'defaults write com.apple.Terminal AppleShowScrollBars -string WhenScrolling',
        'defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseHorizontalScroll -bool NO',
        'sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWOTHERUSERS_MANAGED -bool FALSE',
        'sudo launchctl start com.apple.locate || true',
        'defaults write com.apple.QuickTimePlayerX MGPlayMovieOnOpen 1',
        'defaults write -g NSShowAppCentricOpenPanelInsteadOfUntitledFile -bool false',
        'defaults write com.apple.TextEdit "RichText" -bool "false"',
        'defaults write com.apple.CrashReporter DialogType none',
        'defaults write com.apple.LaunchServices LSQuarantine -bool NO',
        'defaults write com.apple.finder "ShowPathbar" -bool "true"',
        'defaults write com.apple.finder "_FXSortFoldersFirst" -bool "true"',
        'defaults write com.apple.finder "_FXSortFoldersFirstOnDesktop" -bool "true"',
        'defaults write com.apple.finder "FXDefaultSearchScope" -string "SCcf"',
        'defaults write com.apple.finder "FXRemoveOldTrashItems" -bool "true"',
        'defaults write com.apple.finder "FXEnableExtensionChangeWarning" -bool "false"',
        'defaults write NSGlobalDomain "NSTableViewDefaultSizeMode" -int "3"',
        'defaults write com.apple.finder "ShowHardDrivesOnDesktop" -bool "false"',
        'defaults write com.apple.finder "ShowExternalHardDrivesOnDesktop" -bool "false"',
        'defaults write com.apple.finder "ShowRemovableMediaOnDesktop" -bool "false"',
        'defaults write com.apple.finder "ShowMountedServersOnDesktop" -bool "true"',
        'defaults write com.apple.menuextra.clock "FlashDateSeparators" -bool "true"',
        'defaults write com.apple.dock "expose-group-apps" -bool "true"',
        'defaults write com.apple.spaces "spans-displays" -bool "false"',
        %(defaults write com.apple.iphonesimulator "ScreenShotSaveLocation" -string "#{File.join(Dir.home, 'Pictures', 'Screenshots')}"),
        %(defaults write com.apple.screencapture "location" -string "#{File.join(Dir.home, 'Pictures', 'Screenshots')}"),
        'defaults write com.apple.TimeMachine "DoNotOfferNewDisksForBackup" -bool "true"',
        'defaults write com.apple.dock "enable-spring-load-actions-on-all-items" -bool "true"',
        'defaults write com.apple.LaunchServices "LSQuarantine" -bool "false"',
        'defaults write com.apple.Terminal "FocusFollowsMouse" -bool "true"',
        'defaults write com.apple.dock "tilesize" -int "48"',
        'defaults write com.apple.dock "autohide" -bool "true"',
        'defaults write com.apple.dock autohide-delay -float 0',
        'defaults write com.apple.dock autohide-time-modifier -float 0.15',
        'killall Dock',
        'defaults write com.apple.dock "show-recents" -bool "false"',
        'defaults write com.apple.dock "mineffect" -string "suck"',
        'defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false',
        'defaults write -g com.apple.trackpad.scaling 1',
        'defaults write -g com.apple.mouse.scaling 2.0',
        'defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true',
        'defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true',
        'defaults write com.apple.dock tilesize -int 45',
        'defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false',
        'defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false',
        'defaults write com.apple.mail DisableInlineAttachmentViewing -bool true',
        'defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false',
        'launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist'
      ]

      commands.each do |command|
        Bootstrap::System.run(command, allow_failure: true, dry_run: @dry_run)
      end
    end

    alias tweak_macos_configuration tweak_macOS_configuration

    def set_coteditor_as_default_editor
      apply_brew_environment
      duti = find_binary('duti', ['/opt/homebrew/bin/duti'])
      return Bootstrap::Display.warn('duti not found, skipping CotEditor defaults.') if duti.nil?

      Bootstrap::Display.header('Setting CotEditor as default editor for text files')
      commands = [
        "#{duti} -s com.coteditor.CotEditor .txt all",
        "#{duti} -s com.coteditor.CotEditor .log all",
        "#{duti} -s com.coteditor.CotEditor .md  all"
      ]

      commands.each do |command|
        Bootstrap::System.run(command, allow_failure: true, dry_run: @dry_run)
      end
    end

    def add_to_sudoers
      return if @user.nil? || @user.empty?

      Bootstrap::Display.header("Ensuring sudoers entry for #{@user}")

      script = <<~SHELL
        set -e
        sed -i '' -e 's/#includedir/@includedir/' /private/etc/sudoers
        sudoers_path="/private/etc/sudoers.d/sudoers"
        [ -f "$sudoers_path" ] || touch "$sudoers_path"
        entry="#{@user}  ALL=(ALL) NOPASSWD:ALL"
        if ! grep -q "$entry" "$sudoers_path"; then
          echo "$entry" >> "$sudoers_path"
        fi
      SHELL

      Bootstrap::System.run(['sudo', 'bash', '-c', script], dry_run: @dry_run)
    end

    def set_system_hostname(hostname: 'macBook', domain: 'pro')
      fqdn = [hostname, domain].compact.join('.').strip
      Bootstrap::Display.header("Setting system hostname to #{fqdn}")
      Bootstrap::System.run("sudo scutil --set ComputerName #{fqdn}", allow_failure: true, dry_run: @dry_run)
      Bootstrap::System.run("sudo scutil --set LocalHostName #{hostname}", allow_failure: true, dry_run: @dry_run)
      Bootstrap::System.run("sudo scutil --set HostName #{fqdn}", allow_failure: true, dry_run: @dry_run)
    end

    def formula_installed?(formula)
      installed_formulae.include?(formula.split('/').last)
    end

    def cask_installed?(cask)
      installed_casks.include?(cask.split('/').last)
    end

    def package_linked?(dir)
      # Check if all top-level files in the config dir are symlinked in home
      config_path = File.join(@configs_dir, dir)
      return false unless File.directory?(config_path)

      Dir.children(config_path).all? do |child|
        next true if child == '.DS_Store'
        
        source = File.join(config_path, child)
        target = File.join(Dir.home, child)
        
        # If it's a directory in source, stow usually symlinks the contents unless --adopt is used differently
        # But standard stow symlinks the directory itself if it doesn't exist, or contents if it does.
        # Simplest check: does target exist and is it a symlink pointing to source?
        # Stow is complex, but let's check basic symlink existence.
        
        if File.symlink?(target)
          # Check if it points to the right place
          begin
            File.readlink(target) == source || File.readlink(target).include?(source)
          rescue StandardError
            false
          end
        else
          # If target exists and is not a symlink, it's definitely not linked (conflict or adopted)
          # If target doesn't exist, it's not linked
          false
        end
      end
    end

    private

    def installed_formulae
      @installed_formulae ||= begin
        return [] if @dry_run # In dry-run, we might assume nothing is installed or check system?
        # Actually, checking system is fine in dry-run to simulate correctly.
        `#{brew_path} list --formula -1`.split("\n")
      rescue StandardError
        []
      end
    end

    def installed_casks
      @installed_casks ||= begin
        return [] if @dry_run
        `#{brew_path} list --cask -1`.split("\n")
      rescue StandardError
        []
      end
    end

    def prerequisites_ran?
      File.exist?(@prereq_marker) && File.read(@prereq_marker).strip == 'true'
    end

    def mark_prerequisites_done
      File.write(@prereq_marker, 'true')
    end

    def ensure_sudo!
      result = system('sudo -n true')
      return if result

      Bootstrap::Display.info('Password may be required for installation:')
      raise 'Failed to obtain sudo privileges. Exiting.' unless system('sudo -v')

      Bootstrap::Display.info('Sudo access granted.')
    end

    def install_cargo_toolchain
      cargo_path = File.join(Dir.home, '.cargo', 'bin', 'cargo')
      return Bootstrap::Display.info('Cargo already installed.') if File.exist?(cargo_path)

      Bootstrap::Display.header('Installing Rust toolchain')
      Bootstrap::System.run("curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --quiet -y --profile default", dry_run: @dry_run)
    end

    def ensure_homebrew_installed
      return Bootstrap::Display.info('Homebrew already installed.') if find_binary('brew')

      Bootstrap::Display.header('Installing Homebrew')
      install_command = %(printf '\\r' | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)")
      Bootstrap::System.run(install_command, dry_run: @dry_run)
      append_to_file(File.join(Dir.home, '.zprofile'), 'eval "$(/opt/homebrew/bin/brew shellenv)"')
      @brew_path = '/opt/homebrew/bin/brew' if File.exist?('/opt/homebrew/bin/brew')
      apply_brew_environment
    end

    def ensure_stow_installed
      stow = find_binary('stow')
      return Bootstrap::Display.info('GNU Stow already installed.') if stow

      Bootstrap::Display.header('Installing GNU Stow')
      apply_brew_environment
      Bootstrap::System.run("#{brew_path} install --quiet --formula stow", dry_run: @dry_run)
    end

    def run_priority_hooks
      PRIORITY_HOOKS.each do |dir_name|
        install_hook(dir_name) if File.directory?(File.join(@hooks_dir, dir_name))
      end
    end

    def install_hook(dir_name, spinner = nil)
      self.quiet = !!spinner
      if spinner
        spinner.update("Running hooks for #{dir_name}...")
      end
      run_hook(dir_name, :pre)
      run_hook(dir_name, :post)
    ensure
      self.quiet = false
    end

    def run_hook(dir_name, stage)
      script = File.join(@hooks_dir, dir_name, "#{stage}.rb")
      return unless File.exist?(script)

      Bootstrap::Hooks.with_configurator(self) do
        load(script)
      end
    end

    def install_formula(formula, spinner = nil)
      if FORMULAE_DISABLED.include?(formula)
        Bootstrap::Logger.log("Skipping #{formula} (disabled)")
        return
      end

      if formula_installed?(formula)
        Bootstrap::Logger.log("Skipping #{formula} (already installed)")
        return
      end

      path = brew_path
      raise 'Homebrew is not available.' if path.nil?

      if spinner
        spinner.update("Installing #{formula}...")
      else
        Bootstrap::Display.info("Installing #{formula}")
      end
      
      Bootstrap::Logger.log("Installing #{formula}")
      # Use quiet: true if spinner is present to avoid conflict
      Bootstrap::System.run("#{path} install --quiet --formula #{formula}", allow_failure: true, dry_run: @dry_run, quiet: !!spinner)
    end

    def apply_brew_environment
      brew = brew_path
      return if brew.nil?

      command = %(eval "$("#{brew}" shellenv)" && env)
      escaped = command.gsub("'", %q(\\\'))
      output = `bash -lc '#{escaped}'`

      output.each_line do |line|
        key, value = line.strip.split('=', 2)
        next if key.nil? || value.nil?

        ENV[key] = value
      end
    end

    def brew_path
      return @brew_path if defined?(@brew_path) && @brew_path

      candidate = find_binary('brew', ['/opt/homebrew/bin/brew', '/usr/local/bin/brew'])
      @brew_path = candidate
    end

    def find_binary(name, fallbacks = [])
      path = `command -v #{name}`.strip
      return path unless path.nil? || path.empty?

      fallbacks.each do |candidate|
        return candidate if File.exist?(candidate)
      end

      nil
    end

    def validate_directory(directory, name)
      raise "Error: #{name} directory not found." unless File.directory?(directory)
    end

    def append_to_file(path, content)
      return if @dry_run
      FileUtils.touch(path)
      lines = File.read(path).split("\n")
      return if lines.include?(content)

      File.open(path, 'a') { |file| file.puts(content) }
    end
  end
end
