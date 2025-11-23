# frozen_string_literal: true

require_relative '../core/common'
require_relative '../core/library'

Bootstrap::Hooks.run('core', stage: :pre) do |hook|
  configurator = hook.configurator || Bootstrap::Configurator.new

  Bootstrap::Display.header("Adding user #{ENV.fetch('USER', 'unknown')} to sudoers")
  configurator.add_to_sudoers

  configurator.set_system_hostname

  Bootstrap::Display.header('Setting up Python environment (uv)')
  configurator.setup_uv
end

