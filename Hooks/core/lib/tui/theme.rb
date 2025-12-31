# frozen_string_literal: true

require 'pastel'

module Bootstrap
  module TUI
    module Theme
      PASTEL = Pastel.new

      # Modern minimalist color palette
      COLORS = {
        primary: PASTEL.blue.detach,
        success: PASTEL.green.detach,
        warning: PASTEL.yellow.detach,
        error: PASTEL.red.detach,
        muted: PASTEL.dim.detach,
        text: PASTEL.white.detach,
        accent: PASTEL.magenta.detach,
        border: PASTEL.dim.detach
      }.freeze

      # Icons
      ICONS = {
        pending: '○',
        running: '◐',
        done: '●',
        success: '✓',
        error: '✗',
        warning: '⚠',
        info: 'ℹ',
        section: '▸',
        subsection: '•',
        time: '⏱',
        package: '📦',
        config: '⚙',
        hook: '🔗',
        progress_full: '●',
        progress_empty: '○'
      }.freeze

      # Rotating spinner frames
      SPINNER_FRAMES = %w[◐ ◓ ◑ ◒].freeze

      module_function

      def task_icon(task)
        return ICONS[:error] if task.error?
        return ICONS[:success] if task.done?
        return ICONS[:running] if task.running?
        ICONS[:pending]
      end

      def task_color(task)
        return COLORS[:error] if task.error?
        return COLORS[:success] if task.done?
        return COLORS[:primary] if task.running?
        COLORS[:muted]
      end

      def format_task(task, icon: true, color: true)
        prefix = icon ? "#{task_icon(task)} " : ""
        text = task.name

        if color
          task_color(task).call("#{prefix}#{text}")
        else
          "#{prefix}#{text}"
        end
      end

      def format_duration(seconds)
        return "" if seconds.nil? || seconds.zero?

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

      def progress_bar(percent, width: 20)
        filled = (width * percent / 100.0).round
        empty = width - filled

        bar = ICONS[:progress_full] * filled + ICONS[:progress_empty] * empty
        COLORS[:primary].call(bar)
      end

      def section_prefix
        COLORS[:primary].call(ICONS[:section])
      end

      def subsection_prefix
        COLORS[:muted].call(ICONS[:subsection])
      end
    end
  end
end
