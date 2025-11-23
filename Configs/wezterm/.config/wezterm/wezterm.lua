local wezterm = require("wezterm")
local core = require("core")

-- Load configuration modules
local window = core.window
local colors = core.colors
local font = core.font
local keybindings = core.keybindings
local mousebindings = core.mousebindings
local launch_menu = core.launch_menu
local tab_title = core.tab_title
local maximized = core.maximized


local config = {
    check_for_updates = true,
    disable_default_key_bindings = true,
    exit_behavior = "Close",
    default_prog = { '/opt/homebrew/bin/zellij' },
    tab_bar_at_bottom = false,
    use_fancy_tab_bar = true,
    hide_tab_bar_if_only_one_tab = true,
    set_environment_variables = {},
    enable_scroll_bar = true,
    window_frame = {
        border_left_width = 2,
        border_right_width = 2,
        border_top_height = 2,
        border_bottom_height = 2,
        active_titlebar_bg = '#090909'
        -- font = fonts.font,
        -- font_size = fonts.font_size,
    },
    animation_fps = 60,
    max_fps = 60,
    tab_max_width = 25,
    show_tab_index_in_tab_bar = false,

    -- window
    initial_cols = 140, -- Number of columns
    initial_rows = 30,  -- Number of rows

    window_padding = {
        left = 10,
        right = 10,
        top = 10,
        bottom = 10
    },
    window_close_confirmation = 'NeverPrompt',

    inactive_pane_hsb = {
        saturation = 0.9,
        brightness = 0.65
    }
}

-- Merge configurations from modules
for k, v in pairs(window) do
    config[k] = v
end
for k, v in pairs(colors) do
    config[k] = v
end
for k, v in pairs(font) do
    config[k] = v
end
for k, v in pairs(keybindings) do
    config[k] = v
end
for k, v in pairs(mousebindings) do
    config[k] = v
end
for k, v in pairs(launch_menu) do
    config[k] = v
end

-- Configure the tab title formatting
wezterm.on("format-tab-title", tab_title)

-- Maximize the window
wezterm.on("window-config-reloaded", maximized)

return config
