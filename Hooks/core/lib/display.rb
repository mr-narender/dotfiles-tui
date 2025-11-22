# frozen_string_literal: true

require 'io/console'

module Bootstrap
  module Display
    module_function

    def header(text)
      width = console_width - 10
      total = [width - 4, 10].max
      text_width = text.length
      padding = [[(total - text_width) / 2, 0].max, total].min
      separator = '=' * padding
      puts("\n  [ \e[00;35m#{separator} #{text} #{separator}\e[0m ]")
    end

    def info(message)
      puts("[ \e[00;34m..\e[0m ] #{message}")
    end

    def user(message)
      puts("[ \e[0;33m??\e[0m ] #{message}")
    end

    def success(message)
      puts("  [ \e[00;32mOK\e[0m ] #{message}")
    end

    def warn(message)
      puts("  [\e[0;33mWARNING\e[0m] #{message}")
    end

    def fail(message)
      puts("  [\e[0;31mFAIL\e[0m] #{message}")
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

