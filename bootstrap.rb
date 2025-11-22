#!/usr/bin/env ruby

# frozen_string_literal: true

# Set up the Bundler environment
require 'bundler/setup'
require 'optparse'

require_relative './Hooks/core/common'
require_relative './Hooks/core/library'

# Load .env file if it exists
env_file = File.join(File.expand_path(__dir__), '.env')
if File.exist?(env_file)
  File.foreach(env_file) do |line|
    next if line.strip.start_with?('#') || line.strip.empty?

    key, value = line.strip.split('=', 2)
    ENV[key] = value if key && value
  end
end


module Bootstrap
  SCRIPT_DIR = File.expand_path(__dir__)
  HOOKS_DIR = File.join(SCRIPT_DIR, 'Hooks')
  CONFIGS_DIR = File.join(SCRIPT_DIR, 'Configs')
  CORE_DIR = File.join(HOOKS_DIR, 'core')

  ENV['SCRIPT_DIR'] = SCRIPT_DIR
  ENV['HOOKS_DIR'] = HOOKS_DIR
  ENV['CONFIGS_DIR'] = CONFIGS_DIR
  ENV['CORE_DIR'] = CORE_DIR

  class CLI
    attr_reader :options

    def initialize
      @options = {
        link: false,
        unlink: false,
        cask: false,
        formula: false,
        mos: false,
        dry_run: false,
        all: false
      }
    end

    def run
      parse_arguments
      validate_options
      execute
    end

    private

    def display_help
      puts <<~HELP
        Usage: bootstrap.rb [options]
        Options:
          -a, --all       Run all tasks (Link -> Install -> Link)
          -l, --link      Run stow for linking
          -u, --unlink    Run stow for unlinking
          -c, --cask      Run cask installer
          -f, --formula   Run formula installer
          -m, --mos       Install Mac App Store Apps
          -d, --dry-run   Run in dry-run mode (no changes)
          -h, --help      Display this help message
      HELP
      exit
    end

    def parse_arguments
      OptionParser.new do |opts|
        opts.banner = 'Usage: bootstrap.rb [options]'

        opts.on('-a', '--all', 'Run all tasks') { @options[:all] = true }
        opts.on('-l', '--link', 'Run stow for linking') { @options[:link] = true }
        opts.on('-u', '--unlink', 'Run stow for unlinking') { @options[:unlink] = true }
        opts.on('-c', '--cask', 'Run cask installer') { @options[:cask] = true }
        opts.on('-f', '--formula', 'Run formula installer') { @options[:formula] = true }
        opts.on('-m', '--mos', 'Install Mac App Store Apps') { @options[:mos] = true }
        opts.on('-d', '--dry-run', 'Run in dry-run mode') { @options[:dry_run] = true }
        opts.on('-h', '--help', 'Display help') { display_help }

        opts.parse!
      end
    end

    def validate_options
      if @options[:all]
        # If --all is specified, ignore other conflicting flags or just proceed.
        # We can clear others or just let the logic handle it.
        # For simplicity, we'll let the logic handle it.
        return
      end

      if @options[:link] && @options[:unlink]
        abort 'Error: Cannot specify --link and --unlink together.'
      end

      if @options[:cask] && @options[:unlink]
        abort 'Error: Cannot specify --cask and --unlink together.'
      end

      if @options[:formula] && @options[:unlink]
        abort 'Error: Cannot specify --formula and --unlink together.'
      end

      unless @options.values.any?
        puts 'Error: Please specify at least one option.'
        display_help
      end
    end

    def execute
      configurator = Bootstrap::Configurator.new(dry_run: @options[:dry_run])
      run_all = @options[:all]

      # 1. Prerequisites & Install
      if run_all || @options[:formula] || @options[:cask] || @options[:mos]
        Bootstrap::Display.header('Installing prerequisites')
        configurator.pre_requisite
      end

      # 2. Install Formulae
      if run_all || @options[:formula]
        configurator.install_brew_formulas
      end

      # 3. Install Casks
      if run_all || @options[:cask]
        configurator.install_brew_casks
      end

      # 4. Install MOS Apps
      if run_all || @options[:mos]
        configurator.install_mas_apps
      end

      # 5. Unlink (only if explicitly requested)
      if @options[:unlink]
        configurator.unlink_configs
      end

      # 6. Link (Final)
      if run_all || @options[:link]
        Bootstrap::Display.header('Linking Configs')
        configurator.link_configs
      end

      Bootstrap::Display.success('All tasks completed successfully!')
    end
  end
end

Bootstrap::CLI.new.run
