local wezterm = require("wezterm")

local launch_menu = {}

table.insert(launch_menu, {
    label = "PowerShell",
    args = { "pwsh.exe", "-NoLogo" }
})

table.insert(launch_menu, {
    label = "PowerShell (Dev)",
    args = { "pwsh.exe", "-NoLogo" },
    cwd = "C:\\Users\\narendersingh\\dev"
})

table.insert(launch_menu, {
    label = "Command Prompt",
    args = { "cmd.exe" }
})

table.insert(launch_menu, {
    label = "Nu Shell",
    args = { "nu.exe" }
})

table.insert(launch_menu, {
    label = "Ubuntu",
    args = { "wsl.exe", "--distribution", "Ubuntu", "--user", "narender", "--cd", "/home/narender" }
})

return {
    default_domain = "local",
    launch_menu = launch_menu
}
