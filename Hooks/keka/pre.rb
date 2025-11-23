# frozen_string_literal: true

require_relative '../core/common'

Bootstrap::Hooks.run('keka', stage: :pre) do |_hook|
  # No actions defined. Enable this hook via config/hooks.yml when needed.
end
