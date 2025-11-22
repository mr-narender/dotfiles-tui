# frozen_string_literal: true

require_relative '../core/common'
require_relative '../core/library'

Bootstrap::Hooks.run('core', stage: :post) do |hook|
  configurator = hook.configurator || Bootstrap::Configurator.new

  Bootstrap::Display.header('Resetting launchpad')
  configurator.restart_launchpad

  Bootstrap::Display.header('Fixing insecure directory permissions')
  configurator.fix_insecure_dir_problems

  Bootstrap::Display.header('Tweaking system configuration')
  configurator.tweak_macOS_configuration

  Bootstrap::Display.header('Setting default ZSH')
  configurator.change_default_shell

  Bootstrap::Display.success('Core finalisation complete')
end

