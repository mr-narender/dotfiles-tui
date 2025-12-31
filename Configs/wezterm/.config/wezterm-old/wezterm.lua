local wezterm = require("wezterm")
local core = require("core")


-- Load configuration modules
local window = core.window
local colors = core.colors
local font = core.font
local keybindings = core.keyboard
local mousebindings = core.mouse
local launch_menu = core.launch_menu

---@type table<string, any>
local config = {}

config = {
    check_for_updates = true,
    disable_default_key_bindings = true,
    exit_behavior = "Close",
    default_prog = { "powershell.exe" },
    set_environment_variables = {
        PATH = core.load_custom_paths(),
    },
}

-- Merge configurations from modules
local modules = { window, colors, font, keybindings, mousebindings, launch_menu }

for _, module in ipairs(modules) do
  for k, v in pairs(module) do
    config[k] = v
  end
end


-- Configure the tab title formatting
wezterm.on("format-tab-title", core.tab_title)

-- Maximize the window
-- wezterm.on("window-config-reloaded", helper.maximize_window)

return config
