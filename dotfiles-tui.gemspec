# frozen_string_literal: true

require_relative 'lib/dotfiles_tui/version'

Gem::Specification.new do |spec|
  spec.name = 'dotfiles-tui'
  spec.version = DotfilesTui::VERSION
  spec.authors = ['Narender']
  spec.email = ['narender@slrsoft.com']
  
  spec.summary = 'A TUI-based dotfiles bootstrap and management tool'
  spec.description = 'Interactive terminal UI for managing dotfiles, installing packages via Homebrew, and linking configurations with GNU Stow'
  spec.homepage = 'https://github.com/mr-narender/dotfiles-tui'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'
  
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  
  # Specify which files should be added to the gem when it is released.
  # Use git to get all tracked files, which respects .gitignore
  spec.files = if Dir.exist?('.git')
                 `git ls-files -z`.split("\x0").reject do |f|
                   f.match(%r{^(test|spec|features)/}) ||
                   f.include?('_Conflict') ||
                   f.start_with?('config/') ||
                   f == 'config'
                 end
               else
                 Dir.glob('{bin,lib,Hooks,Configs}/**/*', File::FNM_DOTMATCH).reject do |f|
                   File.directory?(f) || 
                   f.include?('.DS_Store') ||
                   f.include?('_Conflict')
                 end + %w[bootstrap.rb Gemfile Gemfile.lock README.md LICENSE]
               end
  
  spec.bindir = 'bin'
  spec.executables = ['dotfiles-tui']
  spec.require_paths = ['lib']
  
  # Runtime dependencies
  spec.add_dependency 'childprocess', '~> 4.1'
  
  # Development dependencies
  spec.add_development_dependency 'rake', '~> 13.0'
end
