local wezterm = require("wezterm")
local helper = require("core.helper")
local windows_keyboard = require("core.bindings.keyboard.windows")
local macos_keyboard = require("core.bindings.keyboard.macos")

local os_name = helper.get_os_name()

local bindings = {}
if os_name == "Windows" or os_name == "Linux" then
    bindings = { bindings = windows_keyboard.bindings }
elseif os_name == "macOS" then
    bindings = { bindings = macos_keyboard.bindings }
end

return bindings
