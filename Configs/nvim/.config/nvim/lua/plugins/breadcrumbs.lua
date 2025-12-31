return { {
    "LunarVim/breadcrumbs.nvim",
    dependencies = {
        { "SmiteshP/nvim-navic" },
    },
    config = function(_, opts)
        require("breadcrumbs").setup()
    end
} }
