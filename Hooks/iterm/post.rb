# frozen_string_literal: true

require_relative '../core/common'

Bootstrap::Hooks.run('iterm', stage: :post) do |_hook|
  # Configure iTerm2 preferences here if desired.
end
