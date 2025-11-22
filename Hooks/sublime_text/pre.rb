# frozen_string_literal: true

require_relative '../core/common'

Bootstrap::Hooks.run('sublime_text', stage: :pre) do |_hook|
  # No actions defined. Enable this hook via config/hooks.yml when needed.
end
