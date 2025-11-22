# Dotfiles Repository

Welcome to my dotfiles repository! This repository contains configuration files for various tools and applications I use on my system. The dotfiles are managed using GNU Stow, a symlink farm manager, which simplifies the process of organizing and managing configuration files across different systems.

## Features

- **GNU Stow Integration:** Utilize the power of GNU Stow for seamless management of dotfiles.
- **Ruby Bootstrap Script:** A robust Ruby script automates the entire process, handling all Stow linking, installation, and hooks.
- **Automated App Installation:** The bootstrap script handles installation of applications via Homebrew and Mac App Store.
- **Dry-Run Mode:** Preview changes before applying them.

## Fresh Installation

To restore your dotfiles on a new machine:

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/your-username/dotfiles.git ~/.dotfiles
    cd ~/.dotfiles/dotfiles.ruby
    ```

2.  **Install Dependencies**:
    Ensure you have Ruby installed (macOS comes with it). Then install the required gems:
    ```bash
    gem install bundler
    bundle install
    ```

3.  **Run the Bootstrap Script**:
    Run the full installation sequence (Install -> Link):
    ```bash
    ruby bootstrap.rb --all
    ```

## Usage Options

### Full Setup
```bash
ruby bootstrap.rb --all
```
Runs the complete workflow: Prerequisites -> Formulae -> Casks -> Mac App Store -> Linking.

### Individual Tasks
- **Link Only**: `ruby bootstrap.rb --link`
- **Install Formulae**: `ruby bootstrap.rb --formula`
- **Install Casks**: `ruby bootstrap.rb --cask`
- **Install App Store Apps**: `ruby bootstrap.rb --mos`
- **Unlink**: `ruby bootstrap.rb --unlink`

### Dry-Run
To see what would happen without making changes:
```bash
ruby bootstrap.rb --dry-run --all
```
