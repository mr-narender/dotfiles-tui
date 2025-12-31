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

  session_path = hook.home_path('.local', 'share', 'atuin', 'session')
  logged_in = File.exist?(session_path)

  if logged_in
    hook.info('Skipping Atuin login: existing session found')
  elsif username && password && key
    hook.run(
      'atuin login --username "$ATUIN_USERNAME" --password "$ATUIN_PASSWORD" --key "$ATUIN_KEY"',
      allow_failure: true,
      env: {
        'ATUIN_USERNAME' => username,
        'ATUIN_PASSWORD' => password,
        'ATUIN_KEY' => key
      }
    )
    logged_in = File.exist?(session_path)
  else
    hook.warn('Skipping Atuin login: Missing credentials in .env')
  end

  if logged_in
    hook.run('atuin sync', allow_failure: true)
  else
    hook.warn('Skipping Atuin sync: No session found')
  end
end
