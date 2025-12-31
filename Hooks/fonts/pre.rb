# frozen_string_literal: true

require 'rbconfig'
require 'tmpdir'
require 'fileutils'
require_relative '../core/common'

def install_fonts_with_curl(hook, destination)
  Dir.mktmpdir do |tmp_dir|
    script = <<~SH
      set -e
      FONT_DIR="#{destination}"
      TMP_DIR="#{tmp_dir}"
      mkdir -p "$FONT_DIR"
      cd "$TMP_DIR"

      curl -s 'https://api.github.com/repos/be5invis/Iosevka/releases/latest' \\
        | jq -r ".assets[] | .browser_download_url" \\
        | grep PkgTTC-Iosevka \\
        | xargs -n 1 curl -L -O --fail --silent --show-error

      find . -name "*.zip" -exec unzip -o "{}" -d "{}_unzipped" \\;
      find . -type f \\( -iname "*.ttf" -o -iname "*.otf" -o -iname "*.ttc" \\) -exec cp "{}" "$FONT_DIR" \\;

      curl -Lso "$TMP_DIR/mono.zip" https://github.com/JetBrains/JetBrainsMono/releases/download/v2.242/JetBrainsMono-2.242.zip
      unzip -q -j -o "$TMP_DIR/mono.zip" '*/ttf/*' -d "$FONT_DIR"

      curl -Lso "$TMP_DIR/hack.zip" https://github.com/source-foundry/Hack/releases/download/v3.003/Hack-v3.003-ttf.zip
      unzip -q -j -o "$TMP_DIR/hack.zip" -d "$FONT_DIR"

      curl -Lso "$TMP_DIR/FiraCode.zip" https://github.com/tonsky/FiraCode/releases/download/5.2/Fira_Code_v5.2.zip
      unzip -q -j -o "$TMP_DIR/FiraCode.zip" -d "$FONT_DIR"
    SH

    hook.run(script, allow_failure: true)
  end
end

Bootstrap::Hooks.run('fonts', stage: :pre) do |hook|
  if RbConfig::CONFIG['host_os'] =~ /darwin/i
    brew = nil
    if hook.configurator&.respond_to?(:send)
      brew = hook.configurator.send(:brew_path) rescue nil
    end
    brew = `command -v brew`.strip if brew.nil? || brew.empty?

    if brew && !brew.empty?
      hook.run("#{brew} install --cask font-iosevka-nerd-font font-maple-mono-nf font-caskaydia-cove-nerd-font font-jetbrains-mono-nerd-font font-hack font-fira-code-nerd-font", allow_failure: true)
    else
      destination = File.join(Dir.home, 'Library', 'Fonts')
      install_fonts_with_curl(hook, destination)
    end
  else
    destination = File.join(Dir.home, '.local', 'share', 'fonts')
    hook.remove_path(destination)
    hook.ensure_directory(destination)
    install_fonts_with_curl(hook, destination)
    hook.run('fc-cache -fv', allow_failure: true)
  end
end
