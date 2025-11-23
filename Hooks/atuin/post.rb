# frozen_string_literal: true

require_relative '../core/common'

Bootstrap::Hooks.run('atuin', stage: :post) do |hook|
  # Load local .env if it exists (injected from Secrets)
  env_file = File.join(__dir__, '.env')
  if File.exist?(env_file)
    File.foreach(env_file) do |line|
      next if line.strip.start_with?('#') || line.strip.empty?

      key, value = line.strip.split('=', 2)
      ENV[key] = value if key && value
    end
  end

  username = ENV.fetch('ATUIN_USERNAME', nil)
  password = ENV.fetch('ATUIN_PASSWORD', nil)
  key = ENV.fetch('ATUIN_KEY', nil)

  if username && password && key
    hook.run("atuin login --username #{username} --password #{password} --key '#{key}'", allow_failure: true)
  else
    Bootstrap::Display.warn('Skipping Atuin login: Missing credentials in .env')
  end
  hook.run('atuin sync')
end
