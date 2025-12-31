local wezterm = require('wezterm')
local common = require("core.common")
local helper = require("core.helper")

local os_name = helper.get_os_name()

-- Load OS-specific configuration
local os_config = {}
if os_name == "Windows" or os_name == "Linux" then
    os_config = require("core.windows")
elseif os_name == "macOS" then
    os_config = require("core.macos")
end

-- Combine common and OS-specific configurations
return {
    -- Common configurations
    utils = common.utils,
    colors = common.colors,
    font = common.font,
    window = common.window,
    tab_title = common.tab_title,

    -- OS-specific configurations
    keyboard = os_config.keyboard or {},
    mouse = os_config.mouse or {},
    default_prog = os_config.default_prog,
    default_cwd = os_config.default_cwd,
    launch_menu = os_config.launch_menu or {}
}
