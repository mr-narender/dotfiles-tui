local wezterm = require("wezterm")

local bindings = {
    keys = {
    { key = "t", mods = "CMD|SHIFT", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
    {
        key = "r",
        mods = "SHIFT|CMD",
        action = wezterm.action.ResetTerminal
    }, {
    key = 'k',
    mods = 'CMD',
    action = wezterm.action.SendString '\x0c'
        }, {
        key = "q",
        mods = "CMD",
        action = wezterm.action.QuitApplication
    }, {
        key = "w",
        mods = "CMD",
        action = wezterm.action.CloseCurrentTab {
            confirm = false
        }
    }, {
        key = "_",
        mods = "SHIFT|CTRL",
        action = wezterm.action.SplitVertical({
            domain = "CurrentPaneDomain"
        })
    }, {
        key = "+",
        mods = "SHIFT|CTRL",
        action = wezterm.action.SplitHorizontal({
            domain = "CurrentPaneDomain"
        })
    }, {
        key = "Tab",
        mods = "SHIFT|CTRL",
        action = wezterm.action.ActivateTabRelative(1)
    }, {
        key = "F11",
        mods = "NONE",
        action = wezterm.action.ToggleFullScreen
    }, {
        key = "+",
        mods = "SHIFT|CMD",
        action = wezterm.action.IncreaseFontSize
    }, {
        key = "-",
        mods = "SHIFT|CMD",
        action = wezterm.action.DecreaseFontSize
    }, {
        key = "C",
        mods = "SHIFT|CMD",
        action = wezterm.action.CopyTo "Clipboard"
    }, {
        key = "N",
        mods = "SHIFT|CMD",
        action = wezterm.action.SpawnWindow
    }, {
        key = "T",
        mods = "SHIFT|CMD",
        action = wezterm.action.ShowLauncher
    }, {
        key = "Enter",
        mods = "SHIFT|CMD",
        action = wezterm.action.ShowLauncherArgs {
            flags = "FUZZY|TABS|LAUNCH_MENU_ITEMS"
        }
    }, {
        key = 'c',
        mods = 'CMD',
        action = wezterm.action.CopyTo 'Clipboard'
    }, -- Paste from clipboard
    {
        key = 'v',
        mods = 'CMD',
        action = wezterm.action.PasteFrom 'Clipboard'
    }, {
        key = "W",
        mods = "SHIFT|CMD",
        action = wezterm.action.CloseCurrentTab {
            confirm = false
        }
    }, {
        key = "PageUp",
        mods = "SHIFT|CMD",
        action = wezterm.action.ScrollByPage(-1)
    }, {
        key = "PageDown",
        mods = "SHIFT|CMD",
        action = wezterm.action.ScrollByPage(1)
    }, {
        key = "UpArrow",
        mods = "SHIFT|CMD",
        action = wezterm.action.ScrollByLine(-1)
    }, {
        key = "DownArrow",
        mods = "SHIFT|CMD",
        action = wezterm.action.ScrollByLine(1)
    }}
}

return {
    bindings = bindings
}
