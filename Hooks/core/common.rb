# frozen_string_literal: true

require_relative 'lib/display'
require_relative 'lib/system'
require_relative 'lib/hook_config'
require_relative 'lib/hook_context'
require_relative 'lib/hooks'

module Bootstrap
  module Common
    module_function

    def header(message)
      Bootstrap::Display.header(message)
    end

    def info(message)
      Bootstrap::Display.info(message)
    end

    def warn(message)
      Bootstrap::Display.warn(message)
    end

    def fail(message)
      Bootstrap::Display.fail(message)
    end

    def success(message)
      Bootstrap::Display.success(message)
    end
  end
end

