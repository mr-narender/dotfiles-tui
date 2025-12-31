# frozen_string_literal: true

require 'open3'
require 'shellwords'

require_relative 'display'

module Bootstrap
  module System
    module_function

    def run(command, allow_failure: false, env: {}, dry_run: false, quiet: false)
      cmd_str = command.is_a?(Array) ? command.join(' ') : command
      
      if dry_run
        # Transient output for dry-run as requested
        # If quiet, we don't print even in dry run? 
        # Actually, in dry run we usually want to see what's happening.
        # But if spinner is active, spinner shows "Installing X".
        # We don't need "Running: brew install X".
        # So yes, respect quiet.
        unless quiet
          Bootstrap::Display.transient("[DRY-RUN] #{cmd_str}")
        end
        # Log it
        Bootstrap::Logger.log("[DRY-RUN] #{cmd_str}")
        return true
      end

      unless quiet
        Bootstrap::Display.transient("Running: #{cmd_str}...")
      end
      Bootstrap::Logger.log("EXEC: #{cmd_str}")

      status = nil
      args = [env]
      if command.is_a?(Array)
        args.concat(command)
      else
        args.push(command)
      end

      output_buffer = ""
      
      # Capture output and log it, but don't print to terminal unless error
      Open3.popen2e(*args) do |_stdin, stdout_err, wait_thread|
        stdout_err.each do |line|
          output_buffer += line
          Bootstrap::Logger.log("  > #{line.strip}")
        end
        status = wait_thread.value
      end

      if status.success?
        # Success: Log it, but do NOT persist to terminal.
        # This ensures the "next line should clear the same line" behavior.
        Bootstrap::Logger.log("COMPLETED: #{cmd_str}")
        return true
      end

      message = "Command failed (#{status.exitstatus}): #{cmd_str}"
      Bootstrap::Logger.error(message)
      Bootstrap::Logger.error("Output:\n#{output_buffer}")
      
      allow_failure ? Bootstrap::Display.warn(message) : raise(message)
    end

    def run!(command, env: {}, dry_run: false, quiet: false)
      run(command, allow_failure: false, env: env, dry_run: dry_run, quiet: quiet)
    end

    def run_script(path, env: {})
      raise "Script not found: #{path}" unless File.exist?(path)

      run!("bash #{Shellwords.escape(path)}", env: env)
    end
  end
end
