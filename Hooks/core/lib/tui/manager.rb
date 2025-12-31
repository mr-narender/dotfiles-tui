# frozen_string_literal: true

module Bootstrap
  module TUI
    class Manager
      attr_reader :tree, :stats, :renderer, :tracker

      def self.instance
        @instance
      end

      def self.create
        @instance = new
      end

      def self.enabled?
        !@instance.nil?
      end

      def initialize
        @tree = TaskTree.new
        @stats = Stats.new
        @tracker = ProgressTracker.new(@tree)
        @renderer = Renderer.new(tree: @tree, stats: @stats)
        @running = false
        @render_thread = nil
        @current_section = nil
        @current_task = nil
        @mutex = Mutex.new
      end

      def start
        @running = true
        @tree.root.start!
        @render_thread = Thread.new { render_loop }
        setup_signal_handlers
      end

      def stop
        @running = false
        @render_thread&.join(2) # Wait up to 2 seconds
        @renderer.render_final
      end

      def start_section(name)
        @mutex.synchronize do
          # Complete previous section if exists
          @current_section&.complete!(success: true) if @current_section && !@current_section.complete?

          @current_section = @tree.add_section(name)
          @current_section.start!
        end
      end

      def complete_section(success: true)
        @mutex.synchronize do
          @current_section&.complete!(success: success)
          @current_section = nil
        end
      end

      def start_task(name, parent: nil)
        @mutex.synchronize do
          parent_task = parent || @current_section || @tree.root
          @current_task = @tree.add_task(name, parent: parent_task)
          @current_task.start!
        end
      end

      def update_task(message)
        @mutex.synchronize do
          # Update current task metadata with progress message
          @current_task.metadata[:message] = message if @current_task
        end
      end

      def complete_task(success: true, message: nil)
        @mutex.synchronize do
          if @current_task
            @current_task.complete!(success: success, message: message)

            # Update stats
            if success
              @stats.success_count += 1
            else
              @stats.error_count += 1
            end

            @current_task = nil
          end
        end
      end

      def skip_task
        @mutex.synchronize do
          if @current_task
            @current_task.skip!
            @stats.skip_count += 1
            @current_task = nil
          end
        end
      end

      def error(message)
        complete_task(success: false, message: message)
      end

      # Batch operations for multiple tasks
      def start_task_group(name:, count:)
        start_section(name)
        @current_section.metadata[:total_count] = count
      end

      def complete_task_group
        complete_section
      end

      private

      def render_loop
        while @running
          begin
            @renderer.render
          rescue => e
            # Log error but don't crash the render loop
            Logger.error("Render error: #{e.message}")
            Logger.error(e.backtrace.join("\n"))
          end
          sleep 0.5 # 2 FPS to match renderer throttle
        end
      end

      def setup_signal_handlers
        Signal.trap('SIGWINCH') do
          @renderer.refresh_terminal_size
        end

        Signal.trap('INT') do
          stop
          puts "\n\n#{Theme::COLORS[:warning].call('Installation interrupted by user')}"
          exit(130)
        end
      end
    end
  end
end
