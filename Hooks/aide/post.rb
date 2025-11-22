# frozen_string_literal: true

require_relative '../core/common'

Bootstrap::Hooks.run('aide', stage: :post) do |_hook|
  # No post actions defined.
end
