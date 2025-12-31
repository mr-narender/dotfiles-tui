local wezterm = require('wezterm')

local function get_os_name()
    local sep = package.config:sub(1, 1)
    if sep == "\\" then
        return "Windows"
    else
        local fh, err = io.popen("uname -s", "r")
        if fh then
            local os_name = fh:read("*l")
            fh:close()
            if os_name == "Linux" then
                return "Linux"
            elseif os_name == "Darwin" then
                return "macOS"
            end
        end
    end
    return "Unknown"
end

local function maximize_window(window, pane)
    window:maximize() -- Maximize the window
end

-- Function to load custom paths depending on the operating system
local function load_custom_paths()
    local system_path = os.getenv("PATH")
    local custom_paths = {}

    -- Choose the correct separator
    local sep = package.config:sub(1,1) == '\\' and ';' or ':'  -- '\' on Windows, '/' on Unix

    if wezterm.target_os == "Windows" then
        table.insert(custom_paths, "C:\\Program Files\\MyCustomBin")
        table.insert(custom_paths, "D:\\Tools")
    elseif wezterm.target_os == "Darwin" then
        table.insert(custom_paths, "/opt/homebrew/bin")
        table.insert(custom_paths, "/usr/local/bin")
    elseif wezterm.target_os == "Linux" then
        table.insert(custom_paths, "/opt/bin")
        table.insert(custom_paths, "/usr/local/bin")
    end

    -- Prepend custom paths to the system path
    local final_path = table.concat(custom_paths, sep)
    if system_path then
        final_path = final_path .. sep .. system_path
    end

    return final_path
end


return {
    get_os_name = get_os_name,
    maximize_window = maximize_window,
    load_custom_paths = load_custom_paths
}
