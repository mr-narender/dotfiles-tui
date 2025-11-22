# frozen_string_literal: true

require_relative '../core/common'

Bootstrap::Hooks.run('aerospace', stage: :pre) do |hook|
  hook.run('/opt/homebrew/bin/brew install --no-quarantine --quiet --cask nikitabobko/tap/aerospace')
  hook.run('/opt/homebrew/bin/brew tap FelixKratz/formulae && /opt/homebrew/bin/brew install --no-quarantine --quiet --formula borders && /opt/homebrew/bin/brew services start felixkratz/formulae/borders')
end
