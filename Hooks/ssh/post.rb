# frozen_string_literal: true

require_relative '../core/common'

Bootstrap::Hooks.run('ssh', stage: :post) do |hook|
  hook.run('find ~/.ssh/ -type f -exec chmod 600 \'{}\' +')
  hook.run('find ~/.ssh/ -type d -exec chmod 700 \'{}\' +')
end
