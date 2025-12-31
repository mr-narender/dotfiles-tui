local wezterm = require("wezterm")
local core = require("core")

local config = wezterm.config_builder()

-- Base configuration
config.check_for_updates = true
config.disable_default_key_bindings = true
config.show_new_tab_button_in_tab_bar = false
config.exit_behavior = "Close"

-- Apply common configurations
for k, v in pairs(core.colors) do
    config[k] = v
end

for k, v in pairs(core.font) do
    config[k] = v
end

for k, v in pairs(core.window) do
    config[k] = v
end

-- Apply OS-specific configurations
if core.keyboard and core.keyboard.keys then
    config.keys = core.keyboard.keys
end

if core.mouse and core.mouse.bindings then
    config.mouse_bindings = core.mouse.bindings
end

if core.default_prog then
    config.default_prog = core.default_prog
end

if core.default_cwd then
    config.default_cwd = core.default_cwd
end

if core.launch_menu then
    config.launch_menu = core.launch_menu
end

if core.default_domain then
    config.default_domain = core.default_domain
end

-- Set up event handlers
wezterm.on("format-tab-title", core.tab_title)

wezterm.on("window-config-reloaded", function(window, pane)
    window:maximize()
end)

return config
