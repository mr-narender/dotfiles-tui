# frozen_string_literal: true

require 'fileutils'
require_relative '../core/common'

Bootstrap::Hooks.run('rectangle', stage: :post) do |hook|
  rectangle_app = '/Applications/Rectangle.app'
  next unless File.directory?(rectangle_app)

  support_dir = File.join(Dir.home, 'Library', 'Application Support', 'Rectangle')
  FileUtils.mkdir_p(support_dir)

  config_source = hook.hook_path('RectangleConfig.json')
  FileUtils.cp(config_source, File.join(support_dir, 'RectangleConfig.json')) if File.exist?(config_source)

  plist_source = hook.hook_path('com.knollsoft.Rectangle.plist')
  preferences_path = File.join(Dir.home, 'Library', 'Preferences', 'com.knollsoft.Rectangle.plist')
  FileUtils.mkdir_p(File.dirname(preferences_path))
  FileUtils.cp(plist_source, preferences_path) if File.exist?(plist_source)

  hook.run('defaults write com.googlecode.iterm2 DisableWindowSizeSnap -integer 1', allow_failure: true)
end
