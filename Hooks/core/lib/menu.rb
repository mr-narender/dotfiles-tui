# frozen_string_literal: true

require 'io/console'

module Bootstrap
  class Menu
    def initialize(options)
      @options = options
      @selected_index = 0
    end

    def show
      print "\e[?25l" # Hide cursor
      loop do
        render
        key = read_key
        case key
        when :up
          @selected_index = (@selected_index - 1) % @options.size
        when :down
          @selected_index = (@selected_index + 1) % @options.size
        when :enter
          print "\e[?25h" # Show cursor
          # Clear the menu
          # Move up by options size + 2 (header + spacing)
          print "\e[#{@options.size + 2}A"
          print "\e[J" # Clear from cursor to end of screen
          return @options[@selected_index][:value]
        when :ctrl_c, :q
          print "\e[?25h" # Show cursor
          puts "\nExiting..."
          exit
        end
      end
    ensure
      print "\e[?25h" # Ensure cursor is shown on exit
    end

    private

    def render
      # Move cursor up by the number of options to overwrite
      print "\e[#{@options.size + 2}A" if @rendered_once
      @rendered_once = true

      puts "\n  \e[1;34mSelect an action (Use Arrow Keys):\e[0m"
      @options.each_with_index do |option, index|
        prefix = index == @selected_index ? "\e[1;32m> \e[0m" : "  "
        label = index == @selected_index ? "\e[1;32m#{option[:label]}\e[0m" : option[:label]
        puts "  #{prefix}#{label}"
      end
    end

    def read_key
      char = STDIN.getch
      if char == "\e"
        char << STDIN.read_nonblock(3) rescue nil
        char << STDIN.read_nonblock(2) rescue nil
      end

      case char
      when "\e[A", "k" then :up
      when "\e[B", "j" then :down
      when "\r", "\n" then :enter
      when "\u0003", "q" then :ctrl_c
      else :unknown
      end
    end
  end
end
