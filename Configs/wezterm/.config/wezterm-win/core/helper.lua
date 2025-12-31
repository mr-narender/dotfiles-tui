local wezterm = require('wezterm')

-- Cache the OS name to avoid repeated system calls
local cached_os_name = nil

local function get_os_name()
    if cached_os_name then
        return cached_os_name
    end

    -- Use wezterm's built-in OS detection instead of spawning processes
    local wezterm = require('wezterm')
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

local function maximize_window(window, pane)
    window:maximize() -- Maximize the window
end

-- Cache the custom paths to avoid repeated environment variable lookups
local cached_custom_paths = nil

-- Function to load custom paths depending on the operating system
local function load_custom_paths()
    if cached_custom_paths then
        return cached_custom_paths
    end

    local wezterm = require('wezterm')
    local system_path = os.getenv("PATH")
    local custom_paths = {}

    -- Choose the correct separator
    local sep = package.config:sub(1,1) == '\\' and ';' or ':'  -- '\' on Windows, '/' on Unix

    if wezterm.target_triple:find("windows") then
        table.insert(custom_paths, "C:\\Users\\narendersingh\\dev")
        table.insert(custom_paths, "D:")
    elseif wezterm.target_triple:find("darwin") then
        table.insert(custom_paths, "/opt/homebrew/bin")
        table.insert(custom_paths, "/usr/local/bin")
    elseif wezterm.target_triple:find("linux") then
        table.insert(custom_paths, "/opt/bin")
        table.insert(custom_paths, "/usr/local/bin")
    end

    -- Prepend custom paths to the system path
    local final_path = table.concat(custom_paths, sep)
    if system_path then
        final_path = final_path .. sep .. system_path
    end

    cached_custom_paths = final_path
    return final_path
end


return {
    get_os_name = get_os_name,
    maximize_window = maximize_window,
    load_custom_paths = load_custom_paths
}
