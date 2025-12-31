# frozen_string_literal: true

require_relative '../core/common'

Bootstrap::Hooks.run('pearcleaner', stage: :pre) do |hook|
  hook.run('/opt/homebrew/bin/brew install --quiet --cask pearcleaner')
end
