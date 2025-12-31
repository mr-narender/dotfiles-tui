# frozen_string_literal: true

require 'shellwords'

require_relative '../core/common'

Bootstrap::Hooks.run('zed', stage: :pre) do |hook|
  hook.run('/opt/homebrew/bin/brew install --quiet --cask zed')

  target_dir = hook.home_path('.config', 'zed')
  expected_dir = File.join(hook.configs_root, hook.name, '.config', 'zed')

  if File.symlink?(target_dir)
    begin
      if File.realpath(target_dir) == expected_dir
        hook.info('Zed config already linked')
        next
      end
    rescue StandardError
      # Fall through to backup logic.
    end
  end

  if File.exist?(target_dir)
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    backup_dir = "#{target_dir}.backup-#{timestamp}"
    hook.info("Backing up existing Zed config to #{backup_dir}")
    hook.run("mv #{Shellwords.escape(target_dir)} #{Shellwords.escape(backup_dir)}")
  end
end
