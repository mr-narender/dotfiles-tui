# frozen_string_literal: true

require_relative '../core/common'

Bootstrap::Hooks.run('iterm', stage: :pre) do |_hook|
  # Add custom installation logic if needed. Disabled by default.
end
