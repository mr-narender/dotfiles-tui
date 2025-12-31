return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
        bigfile = { enabled = true },
        dashboard = { enabled = true },
        indent = { enabled = true },
        input = { enabled = true },
        notifier = { enabled = true },
        quickfile = { enabled = true },
        scope = { enabled = true },
        scroll = { enabled = true },
        statuscolumn = { enabled = true },
        words = { enabled = true },
        explorer = {
            finder = "explorer",
            enabled = true,
            -- your explorer configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
            layout = { position = "right" },
            -- layout = { preset = "sidebar", preview = true, },
            format = "file",
            show_empty = true,
            hidden = true,
            ignored = false,
            follow = false,
            supports_live = true,
        },
        picker = {
            enabled = true,
            layout = {
                position = "right", -- Ensure picker uses right-side layout
            },
            sources = {
                explorer = {
                    -- your explorer picker configuration comes here
                    -- or leave it empty to use the default settings
                    format = "file",
                    show_empty = true,
                    hidden = true,
                    ignored = false,
                    follow = false,
                    supports_live = true,
                }
            },
            -- Other possible configurations (based on what `snacks.nvim` supports)
            prompt_prefix = "▶ ", -- Prefix to display before the prompt
            selection_caret = "→ ", -- Character used to indicate selected item
        }
    },
}
