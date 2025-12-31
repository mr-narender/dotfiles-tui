-- Load configuration modules
local keyboard = require("core.windows.keyboard")
local mouse = require("core.windows.mouse")
local launch = require("core.windows.launch")

return {
    keyboard = keyboard,
    mouse = mouse,
    default_prog = { "pwsh.exe", "-NoLogo" },
    default_cwd = "C:\\Users\\narendersingh",
    launch_menu = launch.launch_menu,
    default_domain = launch.default_domain
}
