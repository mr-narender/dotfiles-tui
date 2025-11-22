# frozen_string_literal: true

require 'fileutils'

require_relative 'display'
require_relative 'system'

module Bootstrap
  class HookContext
    include FileUtils

    attr_reader :name, :stage
    attr_accessor :configurator

    def initialize(name:, stage:, configurator: nil)
      @name = name
      @stage = stage.to_sym
      @configurator = configurator
    end

    def header(message)
      Bootstrap::Display.header(message)
    end

    def info(message)
      Bootstrap::Display.info(message)
    end

    def warn(message)
      Bootstrap::Display.warn(message)
    end

    def success(message)
      Bootstrap::Display.success(message)
    end

    def fail(message)
      Bootstrap::Display.fail(message)
    end

    def run(command, allow_failure: false, env: {})
      Bootstrap::System.run(command, allow_failure: allow_failure, env: env, dry_run: dry_run?)
    end

    def run!(command, env: {})
      Bootstrap::System.run!(command, env: env, dry_run: dry_run?)
    end

    def home_path(*segments)
      File.join(Dir.home, *segments)
    end

    def scripts_root
      ENV.fetch('SCRIPT_DIR', File.expand_path('../../..', __dir__))
    end

    def hooks_root
      ENV.fetch('HOOKS_DIR', File.join(scripts_root, 'Hooks'))
    end

    def configs_root
      ENV.fetch('CONFIGS_DIR', File.join(scripts_root, 'Configs'))
    end

    def hook_path(*segments)
      File.join(hooks_root, name, *segments)
    end

    def ensure_directory(path)
      return if dry_run?
      FileUtils.mkdir_p(path)
    end

    def remove_path(path)
      if dry_run?
        Bootstrap::Display.info("[DRY-RUN] Removing #{path}")
        return
      end

      if File.directory?(path)
        FileUtils.rm_rf(path)
      else
        FileUtils.rm_f(path)
      end
    end

    def copy(source, destination)
      if dry_run?
        Bootstrap::Display.info("[DRY-RUN] Copying #{source} to #{destination}")
        return
      end

      if File.directory?(source)
        FileUtils.cp_r(source, destination)
      else
        ensure_directory(File.dirname(destination))
        FileUtils.cp(source, destination)
      end
    end

    private

    def dry_run?
      @configurator&.dry_run
    end
  end
end
