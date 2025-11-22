# frozen_string_literal: true

require 'rbconfig'
require_relative '../core/common'

Bootstrap::Hooks.run('git', stage: :post) do |hook|
  config_file = File.join(hook.configs_root, 'git', '.gitconfig')
  
  helper = RbConfig::CONFIG['host_os'] =~ /darwin/i ? 'osxkeychain' : 'cache'
  hook.run("git config -f #{config_file} credential.helper #{helper}", allow_failure: true)

  if system('command -v diff-so-fancy >/dev/null 2>&1')
    hook.run("git config -f #{config_file} core.pager \"diff-so-fancy | less --tabs=4 -RFX\"", allow_failure: true)
  end

  if system('command -v code >/dev/null 2>&1')
    hook.run("git config -f #{config_file} merge.tool vscode", allow_failure: true)
    hook.run("git config -f #{config_file} mergetool.vscode.cmd \"code --wait $MERGED\"", allow_failure: true)
  end
end
