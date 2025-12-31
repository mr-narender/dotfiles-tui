local wezterm = require('wezterm')

-- Cache the OS name to avoid repeated system calls
local os_name = nil

-- Cache the custom paths to avoid repeated environment variable lookups
local cached_custom_paths = nil

-- Common method for usage
local function maximize_window(window, pane)
    window:maximize() -- Maximize the window
end


local function get_os_detail()
    if os_name then
        return os_name
    end

    if cached_custom_paths then
        return cached_custom_paths
    end

    local system_path = os.getenv("PATH")
    local custom_paths = {}

    -- Choose the correct separator
    local sep = package.config:sub(1, 1) == '\\' and ';' or ':' -- '\' on Windows, '/' on Unix

    -- Use wezterm's built-in OS detection instead of spawning processes
    if wezterm.target_triple:find("windows") then
        os_name = "Windows"
        table.insert(custom_paths, "C:\\Users\\narendersingh\\dev")
    elseif wezterm.target_triple:find("darwin") then
        os_name = "macOS"
        table.insert(custom_paths, "/opt/homebrew/bin")
        table.insert(custom_paths, "/usr/local/bin")
    elseif wezterm.target_triple:find("linux") then
        os_name = "Linux"
        table.insert(custom_paths, "/opt/bin")
        table.insert(custom_paths, "/usr/local/bin")
    else
        os_name = "Unknown"
    end

    -- Prepend custom paths to the system path
    local os_path = table.concat(custom_paths, sep)
    if system_path then
        os_path = os_path .. sep .. system_path
    end

    return os_name, os_path
end
