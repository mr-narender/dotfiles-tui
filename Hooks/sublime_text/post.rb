# frozen_string_literal: true

require 'fileutils'
require 'rbconfig'
require_relative '../core/common'

Bootstrap::Hooks.run('sublime_text', stage: :post) do |hook|
  mac_app_path = '/Applications/Sublime Text.app'
  sublime_installed = File.directory?(mac_app_path) || system('command -v subl >/dev/null 2>&1')
  next unless sublime_installed

  home_dir = if RbConfig::CONFIG['host_os'] =~ /darwin/i
               File.join(Dir.home, 'Library', 'Application Support', 'Sublime Text')
             else
               File.join(Dir.home, '.config', 'Sublime Text')
             end

  FileUtils.mkdir_p(home_dir)

  archive = hook.hook_path('configuration.zip')
  if File.exist?(archive)
    hook.run("unzip -q '#{archive}' -d '#{home_dir}'", allow_failure: true)
    hook.remove_path(File.join(home_dir, '__MACOSX'))
  end
end
