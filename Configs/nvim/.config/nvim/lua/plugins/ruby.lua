return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = { ensure_installed = { "ruby" } },
    },
    {
        "suketa/nvim-dap-ruby",
        config = function()
            require("dap-ruby").setup()
        end,
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                solargraph = {
                    enabled = false, -- enable Solargraph by default
                    settings = {
                        solargraph = {
                            diagnostics = true,
                            formatting = true,
                        },
                    },
                },
                ruby_lsp = {
                    enabled = true, -- or set to true if you want to use ruby_lsp
                    settings = {
                        rubyLSP = {
                            diagnostics = true,
                            formatting = true,
                        },
                    },
                },
                rubocop = {
                    enabled = formatter == "rubocop" and lsp ~= "solargraph",
                },
                standardrb = {
                    enabled = formatter == "standardrb",
                },
            },
        },
    }
}
