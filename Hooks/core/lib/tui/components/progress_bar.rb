# frozen_string_literal: true

module Bootstrap
  module TUI
    module Components
      class ProgressBar
        attr_reader :percent, :width

        def initialize(percent:, width: 40)
          @percent = percent
          @width = width
        end

        def render
          filled = (width * percent / 100.0).round
          empty = width - filled

          bar = Theme::ICONS[:progress_full] * filled + Theme::ICONS[:progress_empty] * empty
          "#{Theme::COLORS[:primary].call(bar)} #{percent}%"
        end

        def self.render_inline(percent, width: 20)
          new(percent: percent, width: width).render
        end
      end
    end
  end
end
