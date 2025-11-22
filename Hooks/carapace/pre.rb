# frozen_string_literal: true

require_relative '../core/common'

Bootstrap::Hooks.run('carapace', stage: :pre) do |hook|
  hook.run('/opt/homebrew/bin/brew install --no-quarantine --quiet --formula carapace')
end
