# frozen_string_literal: true

module Bootstrap
  module TUI
    class Frame
      attr_reader :components

      def initialize
        @components = []
      end

      def add_component(component)
        @components << component
      end

      def to_s
        @components.map(&:render).join("\n\n")
      end

      def height
        @components.sum { |c| c.respond_to?(:height) ? c.height : 3 }
      end
    end
  end
end
