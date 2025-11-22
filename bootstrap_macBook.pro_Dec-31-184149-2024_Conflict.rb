#!/usr/bin/env ruby

# frozen_string_literal: true

# Ensure dependencies are installed
system('bundle install')

# Set up the Bundler environment
require 'bundler/setup'
require 'io/console'
require 'optparse'

require_relative './Hooks/core/common'
require_relative './Hooks/core/library'

# Main Bootstrap Class
class Bootstrap
  attr_reader :options

  SCRIPT_DIR = File.expand_path(__dir__)
  HOOKS_DIR = File.join(SCRIPT_DIR, 'Hooks')
  CONFIGS_DIR = File.join(SCRIPT_DIR, 'Configs')
  CORE_DIR = File.join(HOOKS_DIR, 'core')

  def initialize
    @options = {
      link: false,
      unlink: false,
      cask: false,
      formula: false,
      mos: false
    }
  end

  # Display help message
  def display_help
    puts <<~HELP
      Usage: #{__FILE__} [options]
      Options:
        -l, --link      Run stow for linking
        -u, --unlink    Run stow for unlinking
        -c, --cask      Run cask installer
        -f, --formula   Run formula installer
        -m, --mos       Install Mac App Store Apps
        -h, --help      Display this help message
    HELP
    exit
  end

  # Parse command-line arguments
  def parse_arguments
    OptionParser.new do |opts|
      opts.banner = 'Usage: bootstrap.rb [options]'

      opts.on('-l', '--link', 'Run stow for linking') { @options[:link] = true }
      opts.on('-u', '--unlink', 'Run stow for unlinking') { @options[:unlink] = true }
      opts.on('-c', '--cask', 'Run cask installer') { @options[:cask] = true }
      opts.on('-f', '--formula', 'Run formula installer') { @options[:formula] = true }
      opts.on('-m', '--mos', 'Install Mac App Store Apps') { @options[:mos] = true }
      opts.on('-h', '--help', 'Display help') { display_help }

      opts.parse!
    end
  end

  # Validate options for conflicts
  def validate_options
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

  # Execute tasks based on options
  def execute
    # Initialize Library
    library = Library.new()

    if @options[:formula] || @options[:cask] || @options[:link] || @options[:mos]
      
      LibraryUtility.header('Installing Pre-requisite')
      library.pre_requisite()
    end

    library.install_brew_formulas if @options[:formula]
    library.install_brew_cask if @options[:cask]
    library.install_mas_apps if @options[:mos]
    library.link_configs if @options[:link]
    library.unlink_configs if @options[:unlink]

    puts 'All tasks completed successfully!'
  end

end

# Main execution
bootstrap = Bootstrap.new()
bootstrap.parse_arguments()
bootstrap.validate_options()
bootstrap.execute()
