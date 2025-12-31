-- Load configuration modules
local window = require("core.window")
local colors = require("core.colors")
local font = require("core.font")
local keyboard = require("core.bindings.keyboard")
local mouse = require("core.bindings.mouse")
local launch_menu = require("core.launch")
local tab_title = require("core.tab_title")
local helper = require("core.helper")

return {
    window = window,
    colors = colors,
    font = font,
    keyboard = keyboard.bindings,
    mouse = mouse.bindings,
    launch_menu = launch_menu,
    tab_title = tab_title,
    maximize_window = helper.maximize_window,
    load_custom_paths = helper.load_custom_paths,
}
