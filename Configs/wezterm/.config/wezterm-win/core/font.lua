local wezterm = require("wezterm")

local config = {}

-- Define your font settings
local font_settings = {
    font = wezterm.font("Iosevka, monospace"),
    font_size = 11.5,
    harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },
}

return font_settings
