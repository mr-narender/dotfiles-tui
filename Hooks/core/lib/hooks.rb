# frozen_string_literal: true

require_relative 'display'
require_relative 'hook_config'
require_relative 'hook_context'

module Bootstrap
  module Hooks
    module_function

    def run(name, stage:, configurator: current_configurator)
      stage = stage.to_sym
      config = Bootstrap::HookConfig.instance

      if config.skipped?(name, stage)
        reason = config.reason_for_skip(name, stage)
        Bootstrap::Display.info("Skipping #{name} #{stage} hook (#{reason})")
        return
      end

      context = Bootstrap::HookContext.new(name: name, stage: stage, configurator: configurator)
      yield context
      Bootstrap::Display.success("#{name} #{stage} hook complete")
    rescue StandardError => e
      Bootstrap::Display.fail("#{name} #{stage} hook failed: #{e.message}")
      raise
    end

    def with_configurator(configurator)
      previous = current_configurator
      self.current_configurator = configurator
      yield
    ensure
      self.current_configurator = previous
    end

    def current_configurator
      Thread.current[:bootstrap_current_configurator]
    end

    def current_configurator=(configurator)
      Thread.current[:bootstrap_current_configurator] = configurator
    end
  end
end
