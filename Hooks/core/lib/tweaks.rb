module Tweaks

  # Helper for writing defaults
  def write_defaults(domain, key, value)
    execute("defaults write #{domain} #{key} #{value}")
  end


  module HomebrewTweaks
    def self.apply
      execute("brew analytics off")
    end
  end

  module FinderTweaks
    def self.apply
      write_defaults("NSGlobalDomain", "AppleShowAllExtensions", "true")
      execute("chflags nohidden ~/Library")
      execute("defaults write com.apple.finder ShowPathbar -bool true")
    end
  end

  module DockTweaks
    def self.apply
      write_defaults("com.apple.dock", "autohide", "true")
      write_defaults("com.apple.dock", "tilesize", "48")
      write_defaults("com.apple.dock", "mineffect", '"suck"')
    end
  end

  module KeyboardMouseTweaks
    def self.apply
      write_defaults("NSGlobalDomain", "KeyRepeat", "2")
      write_defaults("NSGlobalDomain", "InitialKeyRepeat", "15")
      write_defaults("-g", "com.apple.trackpad.scaling", "1")
    end
  end

  module TerminalTweaks
    def self.apply
      write_defaults("com.apple.terminal", "StringEncodings", "-array 4")
      write_defaults("com.apple.Terminal", "FocusFollowsMouse", "true")
    end
  end

  def tweak_macOS_configuration
    HomebrewTweaks.apply
    FinderTweaks.apply
    DockTweaks.apply
    KeyboardMouseTweaks.apply
    TerminalTweaks.apply
    # Add more categories here as needed
  end

  def run_tweaks(modules)
    modules.each { |mod| mod.apply }
  end

end
