local wezterm = require("wezterm")

local bindings = {
    keys = {

    -- Increase font size
    { key = "+", mods = "CTRL", action = wezterm.action.IncreaseFontSize },
    { key = "=", mods = "CTRL", action = wezterm.action.IncreaseFontSize }, -- for some layouts

    -- Decrease font size
    { key = "-", mods = "CTRL", action = wezterm.action.DecreaseFontSize },
    { key = "_", mods = "CTRL|SHIFT", action = wezterm.action.DecreaseFontSize }, -- fallback


    {
        key = 'LeftArrow',
        mods = 'CTRL',
        action = wezterm.action.ActivatePaneDirection 'Left',
      },
      {
        key = 'RightArrow',
        mods = 'CTRL',
        action = wezterm.action.ActivatePaneDirection 'Right',
      },
      {
        key = 'UpArrow',
        mods = 'CTRL',
        action = wezterm.action.ActivatePaneDirection 'Up',
      },
      {
        key = 'DownArrow',
        mods = 'CTRL',
        action = wezterm.action.ActivatePaneDirection 'Down',
      },


    { key = "t", mods = "CTRL", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
    { key = "t", mods = "CTRL|SHIFT", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
    {
        key = 'l',
        mods = 'CTRL',
        action = wezterm.action.Multiple {
         wezterm.action.ClearScrollback "ScrollbackOnly",
         wezterm.action.SendKey { key = "L", mods = "CTRL" },
        },
    },
        {
        key = "q",
        mods = "CTRL",
        action = wezterm.action.QuitApplication
    }, {
        key = "w",
        mods = "CTRL",
        action = wezterm.action.CloseCurrentTab {
            confirm = false
        }
    }, {
        key = "_",
        mods = "SHIFT|ALT",
        action = wezterm.action.SplitVertical({
            domain = "CurrentPaneDomain"
        })
    }, {
        key = "|",
        mods = "SHIFT|ALT",
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
        mods = "SHIFT|CTRL",
        action = wezterm.action.IncreaseFontSize
    }, {
        key = "-",
        mods = "SHIFT|CTRL",
        action = wezterm.action.DecreaseFontSize
    },

    {
        key = 'c',
        mods = 'CTRL',
        action = wezterm.action_callback(
            function(win, pane)
                local has_selection = win:get_selection_text_for_pane(pane) ~= ""
                if has_selection then
                    win:perform_action(wezterm.action.CopyTo 'Clipboard', pane)
                else
                    win:perform_action(wezterm.action.SendKey { key = 'c', mods = 'CTRL' }, pane)
                end
            end
        ),
    },

    {
        key = "N",
        mods = "SHIFT|CTRL",
        action = wezterm.action.SpawnWindow
    }, {
        key = "T",
        mods = "SHIFT|CTRL",
        action = wezterm.action.ShowLauncher
    }, {
        key = "Enter",
        mods = "SHIFT|CTRL",
        action = wezterm.action.ShowLauncherArgs {
            flags = "FUZZY|TABS|LAUNCH_MENU_ITEMS"
        }
    }, {
        key = "v",
        mods = "CTRL",
        action = wezterm.action.PasteFrom "Clipboard"
    }, {
        key = "W",
        mods = "SHIFT|CTRL",
        action = wezterm.action.CloseCurrentTab {
            confirm = false
        }
    }, {
        key = "PageUp",
        mods = "SHIFT",
        action = wezterm.action.ScrollByPage(-1)
    }, {
        key = "PageDown",
        mods = "SHIFT",
        action = wezterm.action.ScrollByPage(1)
    }, {
        key = "UpArrow",
        mods = "SHIFT",
        action = wezterm.action.ScrollByLine(-1)
    }, {
        key = "DownArrow",
        mods = "SHIFT",
        action = wezterm.action.ScrollByLine(1)
    }}
}

return {
    keys = bindings.keys
}
