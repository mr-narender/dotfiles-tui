# frozen_string_literal: true

# Main TUI entry point
require_relative 'tui/task'
require_relative 'tui/task_tree'
require_relative 'tui/progress_tracker'
require_relative 'tui/stats'
require_relative 'tui/theme'
require_relative 'tui/frame'
require_relative 'tui/components/header'
require_relative 'tui/components/progress_bar'
require_relative 'tui/components/tree_view'
require_relative 'tui/components/footer'
require_relative 'tui/renderer'
require_relative 'tui/manager'
require_relative 'tui/builder'

module Bootstrap
  module TUI
    def self.enabled?
      return false unless $stdout.tty?
      return false if ENV['BOOTSTRAP_TUI'] == 'false'
      return false if ENV['CI'] == 'true'
      true
    end

    def self.start(options = {})
      return nil unless enabled?

      begin
        manager = Manager.create
        Builder.new(manager.tree).build_bootstrap_tree(options)
        manager.start
        manager
      rescue => e
        # If TUI fails to start, log and return nil
        Bootstrap::Logger.error("TUI failed to start: #{e.message}")
        Bootstrap::Logger.error(e.backtrace.join("\n"))
        nil
      end
    end

    def self.stop
      Manager.instance&.stop
    end
  end
end
