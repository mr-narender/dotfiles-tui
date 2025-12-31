local wezterm = require("wezterm")
local helper = require("core.helper")
local windows_keyboard = require("core.bindings.keyboard.windows")
local macos_keyboard = require("core.bindings.keyboard.macos")

local os_name = helper.get_os_name()

local bindings = {}
if os_name == "Windows" or os_name == "Linux" then
    bindings = { keys = windows_keyboard.keys }
elseif os_name == "macOS" then
    bindings = { keys = macos_keyboard.keys }
end

return bindings
