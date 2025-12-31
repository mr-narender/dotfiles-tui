# frozen_string_literal: true

module Bootstrap
  module TUI
    class Task
      attr_reader :id, :name, :state, :children, :parent
      attr_reader :started_at, :completed_at, :error_message
      attr_accessor :metadata

      STATES = [:pending, :running, :done, :error, :skipped].freeze

      def initialize(name:, parent: nil, metadata: {})
        @id = object_id
        @name = name
        @state = :pending
        @parent = parent
        @children = []
        @started_at = nil
        @completed_at = nil
        @error_message = nil
        @metadata = metadata

        parent&.add_child(self)
      end

      def add_child(task)
        @children << task
        task.instance_variable_set(:@parent, self)
      end

      def start!
        @state = :running
        @started_at = Time.now
      end

      def complete!(success: true, message: nil)
        @state = success ? :done : :error
        @completed_at = Time.now
        @error_message = message if !success && message
      end

      def skip!
        @state = :skipped
        @completed_at = Time.now
      end

      # Query methods
      def pending?
        @state == :pending
      end

      def running?
        @state == :running
      end

      def done?
        @state == :done
      end

      def error?
        @state == :error
      end

      def skipped?
        @state == :skipped
      end

      def complete?
        done? || error? || skipped?
      end

      def duration
        return nil unless @started_at
        (@completed_at || Time.now) - @started_at
      end

      def leaf?
        @children.empty?
      end

      def section?
        !leaf?
      end

      # Progress calculation
      def total_leaves
        return 1 if leaf?
        @children.sum(&:total_leaves)
      end

      def completed_leaves
        return complete? ? 1 : 0 if leaf?
        @children.sum(&:completed_leaves)
      end

      def progress_percent
        return 100 if complete?
        return 0 if pending?
        return 50 if running? && leaf?

        total = total_leaves
        return 0 if total.zero?
        (completed_leaves.to_f / total * 100).round
      end

      # Tree traversal
      def depth
        parent ? parent.depth + 1 : 0
      end

      def root
        parent ? parent.root : self
      end

      def each_descendant(&block)
        @children.each do |child|
          yield child
          child.each_descendant(&block)
        end
      end

      def find(id)
        return self if @id == id
        @children.each do |child|
          result = child.find(id)
          return result if result
        end
        nil
      end
    end
  end
end
