# frozen_string_literal: true

require 'fileutils'
require_relative '../core/common'

Bootstrap::Hooks.run('vscode', stage: :pre) do |hook|
  user_dir = File.join(Dir.home, 'Library', 'Application Support', 'Code', 'User')
  FileUtils.mkdir_p(user_dir)
end
