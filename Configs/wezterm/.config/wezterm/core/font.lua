local wezterm = require("wezterm")

local config = {}

-- Define your font settings
local font_settings = {
  font = wezterm.font('Hack Nerd Font Mono', { weight = 'Regular', italic = false }),
  font_size = 11.5,
  harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },
}

return font_settings