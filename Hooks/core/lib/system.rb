# frozen_string_literal: true

require 'open3'
require 'shellwords'

require_relative 'display'

module Bootstrap
  module System
    module_function

    def run(command, allow_failure: false, env: {}, dry_run: false)
      if dry_run
        Bootstrap::Display.info("[DRY-RUN] #{command}")
        return true
      end

      status = nil
      Open3.popen2e(env, command) do |_stdin, stdout_err, wait_thread|
        stdout_err.each { |line| puts(line.rstrip) }
        status = wait_thread.value
      end
      return true if status.success?

      message = "Command failed (#{status.exitstatus}): #{command}"
      allow_failure ? Bootstrap::Display.warn(message) : raise(message)
    end

    def run!(command, env: {})
      run(command, allow_failure: false, env: env)
    end

    def run_script(path, env: {})
      raise "Script not found: #{path}" unless File.exist?(path)

      run!("bash #{Shellwords.escape(path)}", env: env)
    end
  end
end
