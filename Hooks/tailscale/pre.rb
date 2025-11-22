# frozen_string_literal: true

require_relative '../core/common'

Bootstrap::Hooks.run('tailscale', stage: :pre) do |hook|
  hook.run('/opt/homebrew/bin/brew install --no-quarantine --quiet --cask tailscale')
end
