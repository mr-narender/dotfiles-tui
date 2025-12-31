# frozen_string_literal: true

module Bootstrap
  module TUI
    class ProgressTracker
      attr_reader :tree, :start_time

      def initialize(tree)
        @tree = tree
        @start_time = Time.now
      end

      def total_tasks
        tree.total_tasks
      end

      def completed_tasks
        tree.completed_tasks
      end

      def remaining_tasks
        total_tasks - completed_tasks
      end

      def percent_complete
        tree.percent_complete
      end

      def elapsed_time
        Time.now - start_time
      end

      def estimated_remaining
        return nil if completed_tasks.zero?
        avg_time_per_task = elapsed_time / completed_tasks
        remaining_tasks * avg_time_per_task
      end

      def tasks_per_second
        return 0 if elapsed_time.zero?
        completed_tasks / elapsed_time
      end

      def progress_bar_data(width: 20)
        filled = (width * percent_complete / 100.0).round
        empty = width - filled
        { filled: filled, empty: empty, percent: percent_complete }
      end
    end
  end
end
