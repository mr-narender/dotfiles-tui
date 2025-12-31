local function Basename(s)
    return s:match("([^/\\]+)$")
end

local function TrimExtension(s)
    return s:gsub("%.%w+$", "")
end

local function CapitalizeFirstLetter(s)
    return s:sub(1, 1):upper() .. s:sub(2)
end
local function format_tab_title(tab, tabs, panes, config, hover, max_width)
    local pane = tab.active_pane
    local title = Basename(pane.foreground_process_name)
    title = CapitalizeFirstLetter(TrimExtension(title))
    
    -- Determine which icon to use based on the foreground process name or OS
    local icon = ""
    local process_name = title:lower()

    -- Icon for shell types and operating systems
    if process_name:match("cmd") then
        icon = "⚙️"  -- icon for cmd
    elseif process_name:match("pwsh") then
        icon = "🔧"  -- icon for PowerShell (pwsh)
    elseif process_name:match("bash") then
        icon = "🐚"  -- icon for Bash
    elseif process_name:match("zsh") then
        icon = "🦄"  -- icon for Zsh
    elseif process_name:match("ubuntu") then
        icon = "🐧"  -- icon for Ubuntu
    elseif process_name:match("debian") then
        icon = "🐧"  -- icon for Debian (same as Ubuntu here, could be different)
    elseif process_name:match("fish") then
        icon = "🐟"  -- icon for Fish shell
    elseif process_name:match("sh") then
        icon = "📜"  -- icon for generic shell (sh)
    else
        icon = "📂"  -- default icon for other processes
    end

    -- Add the icon to the title
    title = icon .. " " .. title
    
    local max_len = max_width or 20
    if #title > max_len then
        title = title:sub(1, max_len - 1) .. "…"
    end
    
    return {{
        Text = "     " .. title .. "     "
    }}
end
return format_tab_title
