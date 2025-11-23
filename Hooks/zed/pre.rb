# frozen_string_literal: true

require_relative '../core/common'

Bootstrap::Hooks.run('zed', stage: :pre) do |hook|
  hook.run('/opt/homebrew/bin/brew install --quiet --cask zed')
end
