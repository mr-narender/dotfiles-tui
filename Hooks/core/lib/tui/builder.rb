# frozen_string_literal: true

module Bootstrap
  module TUI
    class Builder
      attr_reader :tree

      def initialize(tree)
        @tree = tree
      end

      def build_bootstrap_tree(options = {})
        # Create main sections based on bootstrap options
        if options[:all] || options[:link]
          add_prerequisites_section
        end

        if options[:all] || options[:formula]
          add_formulas_section
        end

        if options[:all] || options[:cask]
          add_casks_section
        end

        if options[:all] || options[:mos]
          add_mas_section
        end

        if options[:all] || options[:link]
          add_configs_section
        end

        tree
      end

      private

      def add_prerequisites_section
        section = tree.add_section("Prerequisites")
        tree.add_task("Ensure sudo access", parent: section)
        tree.add_task("Install cargo toolchain", parent: section)
        tree.add_task("Install homebrew", parent: section)
        tree.add_task("Install GNU stow", parent: section)
        tree.add_task("Setup environment file", parent: section)
        tree.add_task("Run priority hooks", parent: section)
      end

      def add_formulas_section
        tree.add_section("Install Homebrew Formulas")
        # Tasks will be added dynamically during execution
      end

      def add_casks_section
        tree.add_section("Install Homebrew Casks")
        # Tasks will be added dynamically during execution
      end

      def add_mas_section
        tree.add_section("Install Mac App Store Apps")
        # Tasks will be added dynamically during execution
      end

      def add_configs_section
        tree.add_section("Link Configuration Files")
        # Tasks will be added dynamically during execution
      end
    end
  end
end
