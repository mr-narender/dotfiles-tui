local wezterm = require("wezterm")
local helper = require("core.helper")
local windows = require("core.keybindings.windows")
local macos = require("core.keybindings.macos")

local os_name = helper.get_os()

local keybindings = {}
if os_name == "Windows" or os_name == "Linux" then
    keybindings = windows.keybindings
elseif os_name == "macOS" then
    keybindings = macos.keybindings

end

return keybindings
