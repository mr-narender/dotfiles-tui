# Dotfiles Management System

A comprehensive, hook-based dotfiles management system built with Ruby and GNU Stow. This repository manages your dotfiles with automated installation, secrets management, and cross-platform configuration support.

## Features

- **Automated Bootstrap**: Interactive TUI for installing and managing all configurations
- **Secrets Management**: Secure handling of sensitive files (SSH keys, API tokens, credentials)
- **Hook System**: Pre and post-installation hooks for custom setup logic
- **Stow Integration**: Symlink-based configuration management
- **Homebrew Integration**: Automated installation of formulae, casks, and Mac App Store apps
- **Cross-Platform**: Support for macOS and Windows configurations
- **Modular Design**: Enable/disable individual configurations via hooks

## Directory Structure

```
~/.dotfiles/
├── bootstrap.rb              # Main bootstrap script
├── bootstrap.sh              # Shell wrapper for bootstrap
├── Gemfile                   # Ruby dependencies
├── .env.example              # Example environment variables
├── .stow-local-ignore        # Files to exclude from stow
├── config/
│   └── hooks.yml             # Hook configuration (enable/disable)
├── Configs/                  # All configuration files
│   ├── zsh/                  # Zsh configuration
│   ├── nvim/                 # Neovim configuration
│   ├── git/                  # Git configuration
│   ├── ssh/                  # SSH configuration (keys in Secrets)
│   ├── aws/                  # AWS configuration (creds in Secrets)
│   ├── tmux/                 # Tmux configuration
│   └── ...                   # More app configs
└── Hooks/                    # Installation hooks
    ├── core/                 # Core bootstrap libraries
    ├── zsh/                  # Zsh hooks
    ├── git/                  # Git hooks
    ├── ssh/                  # SSH hooks
    └── ...                   # More app hooks
```

## Prerequisites

### Required
- **macOS** (primary support) or **Windows** (partial support)
- **Ruby** 2.7 or higher
- **Git**

### Automatically Installed
- **Homebrew** (macOS package manager)
- **GNU Stow** (symlink manager)
- Ruby gems (via Bundler)

## Installation

### 1. Clone the Repository

```bash
# Clone to ~/.dotfiles
git clone git@github.com:mr-narender/dotfiles-tui.git ~/.dotfiles
cd ~/.dotfiles
```

### 2. Install Ruby Dependencies

```bash
# Install bundler if not present
gem install bundler

# Install dependencies
bundle install
```

### 3. Set Up Secrets Directory

Create the secrets directory structure (see [Secrets Management](#secrets-management)):

```bash
mkdir -p ~/Documents/Secrets/{Configs,Hooks}
```

### 4. Run Bootstrap

```bash
# Interactive mode (recommended for first-time setup)
./bootstrap.rb

# Or use bootstrap.sh wrapper
./bootstrap.sh

# Or install everything at once
./bootstrap.rb --all
```

## Usage

### Bootstrap Commands

The `bootstrap.rb` script supports various command-line options:

```bash
# Interactive menu (default)
./bootstrap.rb

# Install everything (recommended)
./bootstrap.rb --all

# Link configurations only
./bootstrap.rb --link

# Install Homebrew formulae only
./bootstrap.rb --formula

# Install Homebrew casks only
./bootstrap.rb --cask

# Install Mac App Store apps only
./bootstrap.rb --mos

# Unlink configurations
./bootstrap.rb --unlink

# Dry run (test without making changes)
./bootstrap.rb --dry-run

# Specify custom secrets path
./bootstrap.rb --secrets-path /path/to/secrets

# Show help
./bootstrap.rb --help
```

### Interactive Menu

When run without arguments, bootstrap presents an interactive menu:

```
┌──────────────────────────────────────┐
│ Dotfiles Bootstrap                   │
├──────────────────────────────────────┤
│ 1. Install Everything (Recommended)  │
│ 2. Link Configs Only                 │
│ 3. Install Formulae                  │
│ 4. Install Casks                     │
│ 5. Install App Store Apps            │
│ 6. Unlink Configs                    │
│ 7. Dry Run (Test All)                │
│ 8. Exit                              │
└──────────────────────────────────────┘
```

### Bootstrap Workflow

When running `--all`, the bootstrap performs these steps in order:

1. **Inject Secrets** - Copy secrets from `~/Documents/Secrets/` to dotfiles
2. **Install Prerequisites** - Install Homebrew and GNU Stow
3. **Install Formulae** - Install command-line tools (via Homebrew)
4. **Install Casks** - Install GUI applications (via Homebrew)
5. **Install MAS Apps** - Install Mac App Store applications
6. **Link Configs** - Create symlinks using GNU Stow

## Secrets Management

### Overview

Sensitive files (SSH keys, API tokens, credentials) are stored separately in `~/Documents/Secrets/` and **never committed to git**.

### Directory Structure

```
~/Documents/Secrets/
├── .env                      # (Optional) Root environment variables
├── Hooks/
│   └── atuin/
│       └── .env              # Atuin credentials
└── Configs/
    ├── ssh/.ssh/
    │   ├── id_rsa            # SSH private key
    │   ├── id_rsa.pub        # SSH public key
    │   ├── config            # SSH configuration
    │   └── known_hosts       # Known SSH hosts
    ├── aws/.aws/
    │   ├── config            # AWS profiles
    │   └── credentials       # AWS access keys
    ├── gpg/.gnupg/
    │   ├── private-keys-v1.d/
    │   ├── pubring.kbx
    │   └── trustdb.gpg
    ├── zsh/.zsh/completion/
    │   ├── exports.zsh       # Environment exports with API tokens
    │   └── secrets.zsh       # Additional secrets
    └── codex/.codex/
        ├── auth.json         # OAuth tokens
        └── config.toml       # Config with credentials
```

### How Secrets Work

1. **Storage**: Actual secrets live in `~/Documents/Secrets/`
2. **Injection**: Bootstrap copies secrets to `~/.dotfiles/` (gitignored)
3. **Linking**: Stow creates symlinks from `~/.dotfiles/` to `~/`
4. **Protection**: All secret files are in `.gitignore`

### Setting Up Secrets

1. **Copy Example Files** (in repository):
   ```bash
   # Use .example files as templates
   cp .env.example .env  # (if needed)
   ```

2. **Create Actual Secrets** (in `~/Documents/Secrets/`):
   ```bash
   # SSH keys
   mkdir -p ~/Documents/Secrets/Configs/ssh/.ssh
   ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
   mv ~/.ssh/id_rsa* ~/Documents/Secrets/Configs/ssh/.ssh/

   # AWS credentials
   mkdir -p ~/Documents/Secrets/Configs/aws/.aws
   # Edit credentials file with your AWS keys
   ```

3. **Run Bootstrap**:
   ```bash
   ./bootstrap.rb --link
   # Secrets will be injected automatically
   ```

### Example Files

The repository includes `.example` files as templates:

- `.env.example` - Environment variables template
- `Configs/ssh/.ssh/config.example` - SSH configuration template
- `Configs/aws/.aws/credentials.example` - AWS credentials template
- `Configs/zsh/.zsh/completion/exports.zsh.example` - Shell exports template
- `Configs/codex/.codex/auth.json.example` - Codex authentication template
- `Configs/codex/.codex/config.toml.example` - Codex configuration template

**Replace placeholders in actual secret files stored in `~/Documents/Secrets/`.**

## Hooks System

### What Are Hooks?

Hooks are Ruby scripts that run before (`pre.rb`) or after (`post.rb`) stow links configurations. They handle:

- Installing dependencies
- Setting up application-specific configurations
- Running initialization commands
- Cleaning up old files

### Hook Structure

Each application can have hooks in `Hooks/<app-name>/`:

```
Hooks/git/
├── pre.rb     # Runs before stow links git configs
└── post.rb    # Runs after stow links git configs
```

### Example Hook

```ruby
# Hooks/git/pre.rb
require_relative '../core/common'

Bootstrap::Hooks.run('git', stage: :pre) do |hook|
  # Remove old config before linking
  hook.remove_path(hook.home_path('.gitconfig'))
end
```

### Enabling/Disabling Hooks

Edit `config/hooks.yml`:

```yaml
excluded_hooks:
  nvchad: true        # Disable nvchad hooks
  tmux: false         # Enable tmux hooks
  starship:
    pre: true         # Disable only pre hook
```

### Available Hook Methods

- `hook.home_path(path)` - Get path in home directory
- `hook.configs_path(path)` - Get path in Configs directory
- `hook.hooks_path(path)` - Get path in Hooks directory
- `hook.remove_path(path)` - Remove file or directory
- `hook.run_command(cmd)` - Execute shell command
- `hook.install_formula(name)` - Install Homebrew formula
- `hook.install_cask(name)` - Install Homebrew cask

## Configuration Management

### Adding a New Configuration

1. **Create Config Directory**:
   ```bash
   mkdir -p Configs/myapp/.config/myapp
   ```

2. **Add Configuration Files**:
   ```bash
   # Add your config files
   # Structure should mirror home directory
   # Example: Configs/myapp/.config/myapp/config.toml
   ```

3. **Create Hooks** (optional):
   ```bash
   mkdir -p Hooks/myapp

   # Create pre-hook
   cat > Hooks/myapp/pre.rb <<'EOF'
   require_relative '../core/common'

   Bootstrap::Hooks.run('myapp', stage: :pre) do |hook|
     # Cleanup or prepare
     hook.remove_path(hook.home_path('.config/myapp'))
   end
   EOF
   ```

4. **Link Configuration**:
   ```bash
   ./bootstrap.rb --link
   ```

### Stow Integration

Stow creates symlinks from `~/.dotfiles/Configs/<app>/` to `~/`:

```
~/.dotfiles/Configs/zsh/.zshrc  →  ~/.zshrc
~/.dotfiles/Configs/nvim/.config/nvim/  →  ~/.config/nvim/
```

Files/folders matching patterns in `.stow-local-ignore` are excluded from linking (e.g., README files, .git directories).

## Application Configurations

### Included Configurations

This repository includes configurations for:

**Shells & Terminals**
- Zsh (with powerlevel10k/starship prompts)
- Tmux
- Alacritty, Ghostty, Kitty, WezTerm, iTerm

**Editors**
- Neovim (LazyVim/NvChad)
- VS Code
- Zed

**Development Tools**
- Git
- Docker
- SSH
- GPG
- AWS CLI
- Atuin (shell history)
- Codex (AI coding assistant)
- Continue (AI code completion)

**Window Management** (macOS)
- Aerospace
- Rectangle
- Borders

**Utilities**
- Stow
- FZF (fuzzy finder)
- MCP (Model Context Protocol)
- Carapace (completion generator)

### Configuration Paths

Each configuration follows the standard for its application:

| App | Config Location | Stowed From |
|-----|----------------|-------------|
| Zsh | `~/.zshrc` | `Configs/zsh/.zshrc` |
| Neovim | `~/.config/nvim/` | `Configs/nvim/.config/nvim/` |
| Git | `~/.gitconfig` | `Configs/git/.gitconfig` |
| SSH | `~/.ssh/config` | `Configs/ssh/.ssh/config` (from Secrets) |
| AWS | `~/.aws/credentials` | `Configs/aws/.aws/credentials` (from Secrets) |
| Tmux | `~/.tmux.conf` | `Configs/tmux/.tmux.conf` |

## Troubleshooting

### Common Issues

**Issue**: "Stow conflicts found"
```bash
# Solution: Unlink first, then relink
./bootstrap.rb --unlink
./bootstrap.rb --link
```

**Issue**: "Secrets not found"
```bash
# Solution: Verify secrets directory structure
ls -la ~/Documents/Secrets/Configs/
# Ensure it mirrors the Configs/ structure
```

**Issue**: "Hook failed to execute"
```bash
# Solution: Disable the problematic hook
# Edit config/hooks.yml and set the hook to true (excluded)
excluded_hooks:
  problematic_app: true
```

**Issue**: "Command not found after linking"
```bash
# Solution: Reload shell configuration
source ~/.zshrc  # or source ~/.bashrc
```

### Dry Run Mode

Test changes without modifying your system:

```bash
./bootstrap.rb --dry-run
# Shows what would be done without executing
```

### Logs

Bootstrap creates detailed logs:

```bash
# Check installation log
cat ~/.dotfiles/install.log
```

## Advanced Usage

### Custom Secrets Location

```bash
./bootstrap.rb --secrets-path /path/to/custom/secrets
```

### Selective Installation

Install only specific components:

```bash
# Install only formulae
./bootstrap.rb --formula

# Link configs and install casks
./bootstrap.rb --link --cask
```

### Uninstalling

```bash
# Unlink all configurations
./bootstrap.rb --unlink

# Remove repository
rm -rf ~/.dotfiles

# (Optional) Remove secrets
# rm -rf ~/Documents/Secrets
```

### Environment Variables

Create `.env` in the repository root for custom environment variables:

```bash
# .env
ATUIN_USERNAME=your_username
ATUIN_PASSWORD=your_password
ATUIN_KEY=your_key
```

**Note**: `.env` is gitignored. Use `.env.example` as a template.

## Contributing

### Adding New Hooks

1. Create hook directory: `Hooks/<app-name>/`
2. Add `pre.rb` and/or `post.rb`
3. Test with dry-run: `./bootstrap.rb --dry-run`
4. Update `config/hooks.yml` if needed

### Adding Configurations

1. Add config to `Configs/<app-name>/`
2. Follow home directory structure
3. Add secrets to `.gitignore` if needed
4. Create example files for secrets
5. Document in this README

### Code Style

- Use Ruby 2.7+ syntax
- Follow existing hook patterns
- Add comments for complex logic
- Test with `--dry-run` before committing

## Security

### Best Practices

1. **Never commit secrets** - Always use `~/Documents/Secrets/`
2. **Review .gitignore** - Ensure sensitive files are excluded
3. **Use example files** - Provide `.example` templates for secrets
4. **Rotate credentials** - If accidentally committed, rotate immediately
5. **Check git history** - Use `git log --all --full-history` to verify

### Gitignored Files

These patterns are automatically excluded from git:

```gitignore
# Secrets
.env
Configs/ssh/.ssh/id_rsa
Configs/ssh/.ssh/config
Configs/ssh/.ssh/known_hosts
Configs/aws/.aws/credentials
Configs/gpg/.gnupg/private-keys-v1.d/
Configs/zsh/.zsh/completion/exports.zsh
Configs/zsh/.zsh/completion/secrets.zsh
Configs/codex/.codex/auth.json
Configs/codex/.codex/config.toml
Configs/codex/.codex/history.jsonl

# System files
.DS_Store
*.log
```

## License

See [LICENSE](LICENSE) file.

## Repository

- **GitHub**: [mr-narender/dotfiles-tui](https://github.com/mr-narender/dotfiles-tui)
- **Issues**: [Report issues](https://github.com/mr-narender/dotfiles-tui/issues)

---

**Happy dotfiles management!** 🚀
