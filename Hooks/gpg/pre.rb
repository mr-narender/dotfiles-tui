# frozen_string_literal: true

require_relative '../core/common'

Bootstrap::Hooks.run('gpg', stage: :pre) do |hook|
  hook.run('gpg --list-secret-keys --with-keygrip', allow_failure: true)
end
