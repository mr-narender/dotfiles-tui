-- Load configuration modules
local keyboard = require("core.macos.keyboard")
local mouse = require("core.macos.mouse")
local launch = require("core.macos.launch")

return {
    keyboard = keyboard,
    mouse = mouse,
    default_prog = { "zsh", "-l" },
    default_cwd = "/Users/narender",
    launch_menu = launch.launch_menu,
    default_domain = launch.default_domain
}
