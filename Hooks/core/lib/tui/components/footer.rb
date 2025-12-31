# frozen_string_literal: true

require 'tty-box'

module Bootstrap
  module TUI
    module Components
      class Footer
        def render(width: 80)
          log_text = "Log: install.log"
          help_text = "Press Ctrl+C to cancel"

          content = "#{log_text}  │  #{help_text}"

          TTY::Box.frame(
            width: width,
            border: :light,
            padding: [0, 1],
            style: {
              fg: :white,
              border: { fg: :bright_black }
            }
          ) do
            content
          end
        end

        private

        def pad_line(text, width)
          visible_length = text.gsub(/\e\[[0-9;]*m/, '').length
          padding = width - visible_length - 4
          text + (' ' * [padding, 0].max)
        end
      end
    end
  end
end
