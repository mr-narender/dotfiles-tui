# frozen_string_literal: true

require_relative '../core/common'

Bootstrap::Hooks.run('ghostty', stage: :pre) do |hook|
  config_path = hook.home_path('.config', 'ghostty')
  hook.remove_path(config_path)
  hook.run('/opt/homebrew/bin/brew install --no-quarantine --quiet --cask ghostty')
end

