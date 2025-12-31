local wezterm = require("wezterm")

local launch_menu = {}

table.insert(launch_menu, {
    label = "zsh",
    args = { "zsh", "-l" }
})

table.insert(launch_menu, {
    label = "Nu Shell",
    args = { "nu" }
})



return {
    default_domain = "local",
    launch_menu = launch_menu
}
