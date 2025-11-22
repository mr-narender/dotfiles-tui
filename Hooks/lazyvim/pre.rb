# frozen_string_literal: true

require_relative '../core/common'

Bootstrap::Hooks.run('lazyvim', stage: :pre) do |hook|
  hook.run('git clone https://github.com/LazyVim/starter ~/.config/nvim')
end
