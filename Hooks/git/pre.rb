# frozen_string_literal: true

require_relative '../core/common'

Bootstrap::Hooks.run('git', stage: :pre) do |hook|
  hook.remove_path(hook.home_path('.gitconfig'))
end
