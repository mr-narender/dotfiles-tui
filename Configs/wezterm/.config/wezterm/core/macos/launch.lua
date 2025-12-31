local wezterm = require("wezterm")

local launch_menu = {}

table.insert(launch_menu, {
    label = "PowerShell",
    args = { "pwsh.exe", "-NoLogo" }
})
table.insert(launch_menu, {
    label = "PowerShell (Dev)",
    args = { "pwsh.exe", "-NoLogo" },
    cwd = "D:"
})
table.insert(launch_menu, {
    label = "PowerShell (Tools)",
    args = { "pwsh.exe", "-NoLogo" },
    cwd = "D:"
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
