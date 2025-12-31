# frozen_string_literal: true

require_relative '../core/common'

Bootstrap::Hooks.run('jujutsu', stage: :pre) do |hook|
  hook.run('/opt/homebrew/bin/brew install --quiet --formula jj')
end
