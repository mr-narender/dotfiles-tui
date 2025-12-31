# frozen_string_literal: true

module Bootstrap
  module TUI
    class Stats
      attr_reader :start_time
      attr_accessor :success_count, :error_count, :skip_count

      def initialize
        @start_time = Time.now
        @success_count = 0
        @error_count = 0
        @skip_count = 0
      end

      def elapsed_time
        Time.now - start_time
      end

      def total_completed
        success_count + error_count + skip_count
      end

      def format_elapsed
        format_duration(elapsed_time)
      end

      def format_estimated_remaining(estimated_seconds)
        return "calculating..." if estimated_seconds.nil?
        format_duration(estimated_seconds)
      end

      private

      def format_duration(seconds)
        return "0s" if seconds.nil? || seconds.zero?

        if seconds < 60
          "#{seconds.round}s"
        elsif seconds < 3600
          minutes = (seconds / 60).floor
          secs = (seconds % 60).round
          "#{minutes}m #{secs}s"
        else
          hours = (seconds / 3600).floor
          minutes = ((seconds % 3600) / 60).floor
          "#{hours}h #{minutes}m"
        end
      end
    end
  end
end
