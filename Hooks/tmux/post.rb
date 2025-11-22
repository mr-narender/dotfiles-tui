# frozen_string_literal: true

require_relative '../core/common'

Bootstrap::Hooks.run('tmux', stage: :post) do |_hook|
  # No post actions defined.
end
