return {
    -- load gruvbox theme
    require("plugins.gruvbox"),

    -- load mason and the treesitter grammar
    require("plugins.mason"),
    require("plugins.treesitter"),

    -- load all the lsp servers
    require("plugins.python"),
    require("plugins.ruby"),
    require("plugins.lua"),
}
