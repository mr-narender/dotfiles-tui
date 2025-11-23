# frozen_string_literal: true

require_relative 'dotfiles_tui/version'

# Main module for DotfilesTui gem
module DotfilesTui
  # Entry point for the CLI
  def self.run
    # Load the bootstrap script
    require_relative '../bootstrap'
    
    # Run the CLI
    Bootstrap::CLI.new.run
  end
end
