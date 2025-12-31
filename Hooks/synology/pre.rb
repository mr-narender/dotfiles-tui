# frozen_string_literal: true

require_relative '../core/common'

Bootstrap::Hooks.run('synology', stage: :pre) do |hook|
  hook.run('/opt/homebrew/bin/brew install --quiet --cask synology-drive', allow_failure: true)
end
