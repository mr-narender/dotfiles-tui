# frozen_string_literal: true

require_relative '../core/common'

Bootstrap::Hooks.run('jujutsu', stage: :post) do |hook|
  unless system('command -v jj >/dev/null 2>&1')
    hook.info('jj not installed; skipping configuration')
    next
  end

  hook.run('jj config set --user user.email "mr.narender@icloud.com"', allow_failure: true)
  hook.run('jj config set --user ui.default-command log', allow_failure: true)
end
