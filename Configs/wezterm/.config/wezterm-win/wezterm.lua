local wezterm = require("wezterm")
local core = require("core")


-- Load configuration modules
local window = core.window
local colors = core.colors
local font = core.font
local keybindings = core.keyboard
local mousebindings = core.mouse
local launch_menu = core.launch_menu
local maximize_window = core.maximize_window

---@type table<string, any>
local config = {}

config = {
    check_for_updates = true,
    disable_default_key_bindings = true,
    show_new_tab_button_in_tab_bar = false,
    -- Remove conflicting color scheme - let colors module handle this
    exit_behavior = "Close",
    default_prog = {"C:\\Users\\narendersingh\\.scoop\\apps\\pwsh\\current\\pwsh.exe", "-NoLogo"},
    default_cwd = "C:\\Users\\narendersingh\\dev",  -- Set default working directory
    set_environment_variables = {
        PATH = core.load_custom_paths(),
    },
}

-- Merge configurations from modules with proper key handling
-- Window configuration
for k, v in pairs(window) do
    config[k] = v
end

-- Colors configuration
for k, v in pairs(colors) do
    config[k] = v
end

-- Font configuration
for k, v in pairs(font) do
    config[k] = v
end

-- Keyboard bindings - handle the nested structure properly
if keybindings and keybindings.keys then
    config.keys = keybindings.keys
end

-- Mouse bindings - handle the nested structure properly
if mousebindings and mousebindings.bindings then
    config.mouse_bindings = mousebindings.bindings
end

-- Launch menu configuration
for k, v in pairs(launch_menu) do
    config[k] = v
end


-- Configure the tab title formatting
wezterm.on("format-tab-title", core.tab_title)

-- Maximize the window
wezterm.on("window-config-reloaded", maximize_window)

return config
