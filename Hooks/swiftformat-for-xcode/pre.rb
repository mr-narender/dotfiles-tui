# frozen_string_literal: true

require_relative '../core/common'

Bootstrap::Hooks.run('swiftformat-for-xcode', stage: :pre) do |hook|
  hook.run('/opt/homebrew/bin/brew install --quiet --cask swiftformat-for-xcode')
end
