-- Load configuration modules
local window = require("core.window")
local colors = require("core.colors")
local font = require("core.font")
local keybindings = require("core.keybindings")
local mousebindings = require("core.mousebindings")
local launch_menu = require("core.launch")
local tab_title = require("core.tab_title")
local maximized = require("core.maximized")

return {
    window = window,
    colors = colors,
    font = font,
    keybindings = keybindings,
    mousebindings = mousebindings,
    launch_menu = launch_menu,
    tab_title = tab_title,
    maximized = maximized
}
