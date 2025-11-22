# frozen_string_literal: true

require_relative '../core/common'

Bootstrap::Hooks.run('transmission', stage: :pre) do |_hook|
  # No actions defined. Enable this hook via config/hooks.yml when needed.
end
