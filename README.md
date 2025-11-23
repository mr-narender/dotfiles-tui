# Dotfiles TUI

A beautiful, interactive terminal UI for managing dotfiles, installing packages, and bootstrapping your development environment.

## Installation

### From RubyGems (Recommended)

```bash
gem install dotfiles-tui
```

### From Source

```bash
git clone https://github.com/yourusername/dotfiles.git
cd dotfiles/dotfiles.ruby
gem build dotfiles-tui.gemspec
gem install ./dotfiles-tui-0.0.1.gem
```

## Usage

Simply run the command to launch the interactive menu:

```bash
dotfiles-tui
```

### Command-line Options

```bash
dotfiles-tui [options]

Options:
  -a, --all             Run all tasks (Link → Install → Link)
  -l, --link            Run stow for linking
  -u, --unlink          Run stow for unlinking
  -c, --cask            Run cask installer
  -f, --formula         Run formula installer
  -m, --mos             Install Mac App Store Apps
  -d, --dry-run         Run in dry-run mode (no changes)
  --secrets-path PATH   Path to secrets directory (default: ~/Documents/Secrets)
  -h, --help            Display help message
```

### Examples

```bash
# Interactive mode (default)
dotfiles-tui

# Install formulae only
dotfiles-tui --formula

# Dry run to see what would happen
dotfiles-tui --all --dry-run

# Link configs with custom secrets path
dotfiles-tui --link --secrets-path ~/my-secrets
```

## Features

- 🎨 **Beautiful TUI** with animated spinners and clean output
- 📦 **Smart Installation** - skips already installed packages
- 🔗 **Intelligent Linking** - detects existing symlinks
- 🔐 **Secrets Management** - inject private configs from external directory
- ⚡ **Fast** - optimized to skip redundant operations
- 🧪 **Dry Run Mode** - preview changes before applying

## Requirements

- Ruby >= 2.7.0
- macOS (for Homebrew features)
- GNU Stow (auto-installed if missing)

## Development

### Building Locally

```bash
gem build dotfiles-tui.gemspec
gem install ./dotfiles-tui-0.0.1.gem
```

### Publishing

The gem is automatically published to RubyGems when you push a version tag:

```bash
# Update version in lib/dotfiles_tui/version.rb
# Commit changes
git tag v0.0.1
git push origin v0.0.1
```

## License

MIT License - see [LICENSE](LICENSE) for details
