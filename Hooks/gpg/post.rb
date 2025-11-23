# frozen_string_literal: true

require_relative '../core/common'

Bootstrap::Hooks.run('gpg', stage: :post) do |hook|
  if system('command -v gpgconf >/dev/null 2>&1')
    hook.run('sudo gpgconf --kill dirmngr', allow_failure: true)
  end

  if File.directory?(hook.home_path('.gnupg'))
    hook.run("sudo chown -R #{ENV['USER']} ~/.gnupg", allow_failure: true)
    hook.run('chmod 700 ~/.gnupg', allow_failure: true)
    hook.run("find ~/.gnupg/ -type f -exec chmod 644 '{}' +", allow_failure: true)
    hook.run("find ~/.gnupg/ -type d -exec chmod 700 '{}' +", allow_failure: true)
  end
end
