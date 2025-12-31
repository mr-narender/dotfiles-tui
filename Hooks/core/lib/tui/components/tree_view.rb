# frozen_string_literal: true

require 'unicode/display_width'

module Bootstrap
  module TUI
    module Components
      class TreeView
        attr_reader :tree, :max_lines

        def initialize(tree, max_lines: 20)
          @tree = tree
          @max_lines = max_lines
        end

        def render
          lines = []

          sections = tree.all_sections

          # Show message if no sections yet
          if sections.empty?
            lines << Theme::COLORS[:muted].call("   Initializing...")
            return lines.join("\n")
          end

          sections.each do |section|
            lines << render_section(section)

            # Always show children for current and completed sections
            if section.running? || section.done?
              # For running sections, show all children
              # For completed sections, show collapsed summary
              if section.running?
                if section.children.empty?
                  lines << Theme::COLORS[:muted].call("   └─ Starting...")
                else
                  section.children.each do |child|
                    lines << render_task(child, indent: 1)
                  end
                end
              elsif section.done?
                # Show summary for completed sections
                completed_count = section.children.count(&:done?)
                total_count = section.children.size
                if total_count > 0
                  lines << "   #{Theme::COLORS[:muted].call("└─ #{completed_count}/#{total_count} items completed")}"
                end
              end
            end

            # Stop if we've hit the line limit
            break if lines.size >= max_lines
          end

          # Add empty line at the end for spacing
          lines << ""

          lines.take(max_lines).join("\n")
        end

        private

        def render_section(section)
          icon = Theme.task_icon(section)
          status_icon = status_indicator(section)
          text = section.name

          prefix = " #{Theme::ICONS[:section]} "
          line = "#{prefix}#{text}"

          # Pad to align status icons on the right
          padding = 75 - visible_length(line)
          "#{line}#{' ' * [padding, 0].max}#{status_icon}"
        end

        def render_task(task, indent: 0)
          icon = Theme.task_icon(task)
          text = task.name
          indent_str = '   ' * indent

          # Color the text based on status
          colored_text = if task.done?
            Theme::COLORS[:success].call(text)
          elsif task.running?
            Theme::COLORS[:primary].call(text)
          elsif task.error?
            Theme::COLORS[:error].call(text)
          else
            Theme::COLORS[:muted].call(text)
          end

          line = "#{indent_str} #{icon} #{colored_text}"

          # Add error message if present
          if task.error? && task.error_message
            line += Theme::COLORS[:error].call(" (#{task.error_message})")
          end

          line
        end

        def status_indicator(task)
          return Theme::COLORS[:success].call(Theme::ICONS[:success]) if task.done?
          return Theme::COLORS[:error].call(Theme::ICONS[:error]) if task.error?
          return Theme::COLORS[:primary].call(Theme::ICONS[:running]) if task.running?
          Theme::COLORS[:muted].call(Theme::ICONS[:pending])
        end

        def all_children_collapsed?(task)
          # Only collapse if all children are done and it was >5 seconds ago
          return false unless task.done?
          return false if task.completed_at.nil?
          (Time.now - task.completed_at) < 2
        end

        def visible_length(text)
          # Remove ANSI codes and calculate actual display width
          text.gsub(/\e\[[0-9;]*m/, '').length
        end
      end
    end
  end
end
