local wezterm = require("wezterm")
local helper = require("core.helper")

-- Cache the OS name and launch menu to avoid repeated calculations
local os_name = helper.get_os_name()
-- print("Operating System: " .. os_name)

local launch_menu = {}

if os_name == "Windows" then
    table.insert(launch_menu, {
        label = "PowerShell",
        args = {"C:\\Users\\narendersingh\\.scoop\\apps\\pwsh\\current\\pwsh.exe", "-NoLogo"}
    })
    table.insert(launch_menu, {
        label = "PowerShell (Dev)",
        args = {"C:\\Users\\narendersingh\\.scoop\\apps\\pwsh\\current\\pwsh.exe", "-NoLogo"},
        cwd = "D:"
    })
    table.insert(launch_menu, {
        label = "PowerShell (Tools)",
        args = {"C:\\Users\\narendersingh\\.scoop\\apps\\pwsh\\current\\pwsh.exe", "-NoLogo"},
        cwd = "D:"
    })
    table.insert(launch_menu, {
        label = "Nu Shell",
        args = {"C:\\Users\\narendersingh\\.scoop\\apps\\nu\\current\\nu.exe"}
    })
    table.insert(launch_menu, {
        label = "Ubuntu",
        args = {"wsl.exe", "--distribution", "Ubuntu", "--user", "narender", "--cd", "/home/narender"}
    })
elseif os_name == "macOS" or os_name == "Linux" then
    table.insert(launch_menu, {
        label = "fish",
        args = {"fish", "-l"}
    })
    table.insert(launch_menu, {
        label = "zsh",
        args = {"zsh", "-l"}
    })
end


return {
    default_domain = "local",
    launch_menu = launch_menu
}
