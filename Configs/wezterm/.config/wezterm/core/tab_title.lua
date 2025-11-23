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
    local max_len = max_width or 20
    if #title > max_len then
        title = title:sub(1, max_len - 1) .. "…"
    end
    return {{
        Text = "     " .. title .. "     "
    }}
end

return format_tab_title
