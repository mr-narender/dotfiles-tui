# frozen_string_literal: true

require_relative 'display'

module Bootstrap
  class Spinner
    FRAMES = %w[⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏].freeze
    INTERVAL = 0.1

    def self.spin(message)
      # Don't show spinner when TUI is active
      if Display.tui
        yield NullSpinner.new
        return
      end

      spinner = new(message)
      spinner.start
      begin
        yield spinner
      ensure
        spinner.stop
      end
    end

    def initialize(message)
      @message = message
      @stop = false
      @mutex = Mutex.new
    end

    def update(message)
      @mutex.synchronize { @message = message }
    end

    def start
      @thread = Thread.new do
        i = 0
        loop do
          break if @stop
          frame = FRAMES[i % FRAMES.length]
          msg = @mutex.synchronize { @message }
          print "\r\e[K  [ \e[1;34m#{frame}\e[0m ] #{msg}"
          i += 1
          sleep INTERVAL
        end
      end
    end

    def stop
      @stop = true
      @thread.join if @thread
      print "\r\e[K"
    end
  end

  # Null object pattern for when spinner is disabled
  class NullSpinner
    def update(message)
      # Do nothing
    end
  end
end
