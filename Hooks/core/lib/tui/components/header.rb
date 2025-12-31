# frozen_string_literal: true

require 'tty-box'

module Bootstrap
  module TUI
    module Components
      class Header
        attr_reader :stats, :tree

        def initialize(stats, tree)
          @stats = stats
          @tree = tree
        end

        def render(width: 80)
          progress_percent = tree.percent_complete
          completed = tree.completed_tasks
          total = tree.total_tasks
          remaining = total - completed
          elapsed = stats.format_elapsed

          title = "Bootstrap Installation"
          progress_visual = progress_bar(progress_percent, width: 4)

          line1 = "#{title}#{' ' * 10}#{progress_percent}% #{progress_visual}"
          line2 = "#{Theme::ICONS[:time]}  #{elapsed}  │  #{completed}/#{total} complete  │  #{remaining} remaining"

          TTY::Box.frame(
            width: width,
            border: :light,
            padding: [0, 1],
            style: {
              fg: :white,
              border: { fg: :bright_black }
            }
          ) do
            "#{line1}\n#{line2}"
          end
        end

        private

        def progress_bar(percent, width:)
          filled = (width * percent / 100.0).round
          empty = width - filled
          Theme::ICONS[:progress_full] * filled + Theme::ICONS[:progress_empty] * empty
        end

        def pad_line(text, width)
          # Remove ANSI codes for length calculation
          visible_length = text.gsub(/\e\[[0-9;]*m/, '').length
          padding = width - visible_length - 4 # Account for box borders
          text + (' ' * [padding, 0].max)
        end
      end
    end
  end
end
