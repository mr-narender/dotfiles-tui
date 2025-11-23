local wezterm = require("wezterm")
local helper = require("core.helper")

local os_name = helper.get_os()
-- print("Operating System: " .. os_name)

local launch_menu = {
    launch_menu = {}
}

if os_name == "Windows" then
    if wezterm.target_triple == "x86_64-pc-windows-msvc" then
        table.insert(launch_menu.launch_menu, {
            label = "PowerShell",
            args = {"C:\\Program Files\\PowerShell\\7\\pwsh.exe"}
        })
        table.insert(launch_menu.launch_menu, {
            label = "Command Prompt",
            args = {"cmd.exe"}
        })
        table.insert(launch_menu.launch_menu, {
            label = "PowerShell 7",
            args = {"pwsh.exe", "-NoLogo"}
        })
        table.insert(launch_menu.launch_menu, {
            label = "Git Bash",
            args = {"C:\\Program Files\\Git\\bin\\bash.exe"}
        })
    else
        table.insert(launch_menu.launch_menu, {
            label = "fish",
            args = {"fish", "-l"}
        })
        table.insert(launch_menu.launch_menu, {
            label = "zsh",
            args = {"zsh", "-l"}
        })
    end
end

return launch_menu
