-- Cache icon mappings for better performance
local process_icons = {
    cmd = "🧛",
    powershell = "🧛",
    pwsh = "🔱",
    nu = "🐚",
    bash = "🐚",
    zsh = "🦄",
    ubuntu = "🐧",
    wslhost = "🐧",
    debian = "🌀",
    wsl = "🌀",
    fish = "🐟",
    sh = "📜"
}

local function Basename(s)
    return s:match("([^/\\]+)$")
end

local function TrimExtension(s)
    return s:gsub("%.%w+$", "")
end

local function CapitalizeFirstLetter(process_name)
    -- Remove '.exe' if it exists at the end
    process_name = process_name:gsub("%.exe$", "")
    -- Capitalize the first letter
    return process_name:sub(1, 1):upper() .. process_name:sub(2)
end


local function format_tab_title(tab, tabs, panes, config, hover, max_width)
    local pane = tab.active_pane
    local title = Basename(pane.foreground_process_name)
    title = CapitalizeFirstLetter(TrimExtension(title))

    -- Use cached icon mapping for better performance
    local process_name = title:lower()
    local icon = process_icons[process_name] or "📂"  -- default icon

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
