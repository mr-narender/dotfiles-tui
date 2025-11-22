# frozen_string_literal: true

require_relative '../core/common'

Bootstrap::Hooks.run('zoxide', stage: :pre) do |hook|
  hook.run('/opt/homebrew/bin/brew install --formula zoxide')
end
