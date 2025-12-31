# frozen_string_literal: true

module Bootstrap
  module TUI
    class TaskTree
      attr_reader :root

      def initialize(root_name: "Bootstrap Installation")
        @mutex = Mutex.new
        @root = Task.new(name: root_name)
      end

      def add_section(name, parent: @root)
        @mutex.synchronize do
          Task.new(name: name, parent: parent)
        end
      end

      def add_task(name, parent:)
        @mutex.synchronize do
          Task.new(name: name, parent: parent)
        end
      end

      def find_task(id)
        @mutex.synchronize do
          @root.find(id)
        end
      end

      def update_task(id, &block)
        @mutex.synchronize do
          task = @root.find(id)
          block.call(task) if task
        end
      end

      def total_tasks
        @root.total_leaves
      end

      def completed_tasks
        @root.completed_leaves
      end

      def percent_complete
        return 0 if total_tasks.zero?
        (completed_tasks.to_f / total_tasks * 100).round
      end

      def all_sections
        @root.children
      end

      def current_section
        all_sections.find(&:running?) || all_sections.find(&:pending?)
      end

      def current_task
        find_running_task(@root)
      end

      def each_task(&block)
        @root.each_descendant(&block)
      end

      private

      def find_running_task(task)
        return task if task.running? && task.leaf?
        task.children.each do |child|
          result = find_running_task(child)
          return result if result
        end
        nil
      end
    end
  end
end
