local wezterm = require("wezterm")
local helper = require("core.helper")

local os_name = helper.get_os_name()

-- OS-specific font size adjustments
local font_size = 12.0
if os_name == "macOS" then
    font_size = 18.0
elseif os_name == "Windows" then
    font_size = 13.0
elseif os_name == "Linux" then
    font_size = 13
end

-- Define font configurations with proper fallbacks
local font_settings = {
    font = wezterm.font_with_fallback {
        {
            family = "Iosevka",
            weight = "Regular",
            stretch = "Normal",
            style = "Normal",
        },
        {
            family = "JetBrains Mono",
            weight = "Regular",
            stretch = "Normal",
            style = "Normal",
        },
        {
            family = "Fira Code",
            weight = "Regular",
            stretch = "Normal",
            style = "Normal",
        },
        {
            family = "Cascadia Code",
            weight = "Regular",
            stretch = "Normal",
            style = "Normal",
        },
        {
            family = "SF Mono",
            weight = "Regular",
            stretch = "Normal",
            style = "Normal",
        },
        {
            family = "Monaco",
            weight = "Regular",
            stretch = "Normal",
            style = "Normal",
        },
        {
            family = "Consolas",
            weight = "Regular",
            stretch = "Normal",
            style = "Normal",
        },
        {
            family = "Courier New",
            weight = "Regular",
            stretch = "Normal",
            style = "Normal",
        },
        "monospace"
    },
    font_size = font_size,
    harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },
    line_height = 1.2,
    cell_width = 1.0,
    freetype_load_target = "Normal",
    freetype_render_target = "Normal",
}

return font_settings
