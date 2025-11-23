# frozen_string_literal: true

require 'fileutils'
require_relative '../core/common'

Bootstrap::Hooks.run('vscode', stage: :post) do |hook|
  code_binary = `command -v code`.strip
  next if code_binary.empty?

  extensions_file = hook.hook_path('extensions.txt')
  if File.exist?(extensions_file)
    File.read(extensions_file).split.each do |extension|
      next if extension.strip.empty?

      hook.run("#{code_binary} --install-extension #{extension.strip} --force", allow_failure: true)
    end
  end

  user_dir = File.join(Dir.home, 'Library', 'Application Support', 'Code', 'User')
  FileUtils.mkdir_p(user_dir)

  %w[keybindings.json settings.json style.css].each do |file_name|
    source = hook.hook_path(file_name)
    next unless File.exist?(source)

    destination = File.join(user_dir, file_name)
    hook.copy(source, destination)
  end
end
