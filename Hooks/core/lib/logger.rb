# frozen_string_literal: true

module Bootstrap
  class Logger
    LOG_FILE = 'install.log'

    class << self
      def init
        File.write(LOG_FILE, "Bootstrap Log - #{Time.now}\n========================================\n\n")
      end

      def log(message)
        File.open(LOG_FILE, 'a') do |f|
          f.puts("[#{Time.now.strftime('%H:%M:%S')}] #{message}")
        end
      end

      def error(message)
        log("ERROR: #{message}")
      end
    end
  end
end
