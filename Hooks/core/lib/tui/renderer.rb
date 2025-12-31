# frozen_string_literal: true

require 'tty-screen'
require 'tty-cursor'

module Bootstrap
  module TUI
    class Renderer
      attr_reader :tree, :stats

      def initialize(tree:, stats:)
        @tree = tree
        @stats = stats
        @first_render = true
        @last_render_time = Time.now - 1
        refresh_terminal_size
      end

      def render
        # Throttle rendering to avoid aggressive refreshing
        return if Time.now - @last_render_time < 0.5 # Max 2 FPS
        @last_render_time = Time.now

        if @first_render
          puts "\n" # Initial spacing
          @first_render = false
        end

        frame = build_frame
        output = frame.to_s

        # Clear previous output and render new frame
        # Calculate how many lines to clear
        lines_to_clear = @last_frame_lines || 0

        # Move up and clear previous frame
        if lines_to_clear > 0
          print TTY::Cursor.up(lines_to_clear)
          print TTY::Cursor.clear_screen_down
        end

        # Render new frame
        print output
        $stdout.flush

        # Count lines for next render
        @last_frame_lines = output.lines.count
      end

      def render_final
        # Just add some spacing at the end
        puts "\n"
      end

      def refresh_terminal_size
        @terminal_height = TTY::Screen.height
        @terminal_width = [TTY::Screen.width, 80].min
      end

      private

      def build_frame
        Frame.new.tap do |f|
          f.add_component(Components::Header.new(@stats, @tree))
          f.add_component(Components::TreeView.new(@tree, max_lines: max_tree_lines))
          f.add_component(Components::Footer.new) unless compact_mode?
        end
      end

      def max_tree_lines
        if compact_mode?
          [@terminal_height - 8, 5].max
        else
          [@terminal_height - 10, 15].max
        end
      end

      def compact_mode?
        @terminal_height < 24
      end

      def clear_screen
        print TTY::Cursor.clear_screen
      end

      def hide_cursor
        print TTY::Cursor.hide
      end

      def show_cursor
        print TTY::Cursor.show
      end
    end
  end
end
