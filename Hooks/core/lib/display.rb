# frozen_string_literal: true

require 'io/console'

module Bootstrap
  module Display
    module_function

    def header(text)
      width = 80 # Fixed width as requested
      text_len = text.length
      padding = [(width - text_len - 2) / 2, 0].max
      
      # Double border style
      top_border = "╔#{'═' * width}╗"
      bottom_border = "╚#{'═' * width}╝"
      
      left_pad_len = padding
      right_pad_len = width - text_len - left_pad_len
      
      left_pad = ' ' * left_pad_len
      right_pad = ' ' * right_pad_len
      
      # Cyan border, Bold White text
      content = "║#{left_pad}\e[1;37m#{text}\e[0m#{right_pad}║"

      puts
      puts "  \e[0;36m#{top_border}\e[0m"
      puts "  \e[0;36m#{content}\e[0m"
      puts "  \e[0;36m#{bottom_border}\e[0m"
      puts
    end

    def info(message)
      # Log to file
      Bootstrap::Logger.log(message)
      # Transient output to terminal
      transient(message)
    end
    
    def transient(message)
      # Clear line and print message
      # \r moves to beginning of line
      # \e[K clears from cursor to end of line
      print "\r\e[K  [ \e[0;34m🚀\e[0m ] #{message}"
      $stdout.flush
    end

    def persist(message, status = :success)
      # Make the current line permanent with a status
      # \r moves to beginning
      # \e[K clears line
      
      case status
      when :success
        # Transient success: overwrite the line
        print "\r\e[K  [ \e[0;32m✔\e[0m ] #{message}"
        $stdout.flush
      when :error
        # Errors persist
        puts "\r\e[K  [\e[0;31m✖\e[0m] #{message}"
      when :warn
        # Warnings persist
        puts "\r\e[K  [\e[0;33m⚠\e[0m] #{message}"
      end
    end

    def user(message)
      puts("[ \e[0;33m??\e[0m ] #{message}")
    end

    def success(message)
      Bootstrap::Logger.log("SUCCESS: #{message}")
      persist(message, :success)
    end

    def warn(message)
      Bootstrap::Logger.log("WARNING: #{message}")
      persist(message, :warn)
    end

    def fail(message)
      Bootstrap::Logger.error(message)
      persist(message, :error)
      exit(1)
    end

    def wait_for_confirmation(prompt: "\nPress (y/Y) when ready:")
      print("#{prompt} ")
      loop do
        char = read_single_character
        return true if %w[y Y].include?(char)

        print("\nInvalid choice: #{char}. #{prompt} ")
      end
    ensure
      puts
    end



    def console_width
      IO.console.winsize[1]
    rescue StandardError
      120
    end

    def read_single_character
      char = nil
      begin
        system('stty raw -echo')
        char = STDIN.getc
      ensure
        system('stty -raw echo')
      end
      char.chr
    end
  end
end

