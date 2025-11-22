# frozen_string_literal: true

require_relative '../core/common'

Bootstrap::Hooks.run('rectangle', stage: :pre) do |_hook|
  # Rectangle installation disabled by default.
end
