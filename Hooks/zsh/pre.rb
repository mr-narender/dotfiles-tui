# frozen_string_literal: true

require_relative '../core/common'

Bootstrap::Hooks.run('zsh', stage: :pre) do |hook|
  zap_dir = File.join(Dir.home, '.local', 'share', 'zap')
  unless Dir.exist?(zap_dir)
    hook.run('curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh | zsh -s -- --branch release-v1', allow_failure: true)
  end

  zap_script = File.join(ENV.fetch('XDG_DATA_HOME', File.join(Dir.home, '.local', 'share')), 'zap', 'zap.zsh')
  if File.exist?(zap_script) && File.exist?(File.join(Dir.home, '.zshrc'))
    hook.remove_path(File.join(Dir.home, '.zshrc'))
  end

  %w[.zprofile .profile .zshenv .zsh_history].each do |file|
    hook.remove_path(File.join(Dir.home, file))
  end
end
