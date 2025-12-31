return {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    config = function()
        local configs = require("nvim-treesitter.configs")
        configs.setup({
            ensure_installed = {
                "lua",
                "vim",
                "vimdoc",
                "html",
                "python",
                "ruby",
                "sql",
                "regex",
                "bash",
                "yaml",
                "json",
                "jsonc",
                "csv",
                "javascript",
                "dockerfile",
            },
            auto_install = true,
            sync_install = false,
            highlight = { enable = true },
            indent = { enable = true },
        })
    end
}
