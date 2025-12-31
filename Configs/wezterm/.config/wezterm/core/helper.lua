local wezterm = require('wezterm')

local cached_os_name = nil

local function get_os_name()
    if cached_os_name then
        return cached_os_name
    end

    if wezterm.target_triple:find("windows") then
        cached_os_name = "Windows"
    elseif wezterm.target_triple:find("darwin") then
        cached_os_name = "macOS"
    elseif wezterm.target_triple:find("linux") then
        cached_os_name = "Linux"
    else
        cached_os_name = "Unknown"
    end

    return cached_os_name
end

return {
    get_os_name = get_os_name
}
