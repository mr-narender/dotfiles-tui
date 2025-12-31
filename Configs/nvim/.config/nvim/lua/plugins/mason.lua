-- Require your Python path utility once
local python = require("utils.python")
local python_path = python.get_python_path()

-- Set Python host program for Neovim only if valid
if python_path and python_path ~= "" then
    vim.g.python3_host_prog = python_path
end

return { -- Mason: package manager
{
    "mason-org/mason.nvim",
    opts = {
        ensure_installed = {"pyright", "ruff" -- You can add "debugpy" if you're using nvim-dap-python
        },
        automatic_installation = true,
        PATH = "prepend", -- add Mason bins to PATH
        pip = {
            upgrade_pip = true,
            install_args = {"--no-cache-dir"}
        }
    },
    config = function()
        require("mason").setup({
            PATH = "prepend",
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗"
                }
            },
            pip = {
                upgrade_pip = true,
                install_args = {}
            }
        })
    end
}, -- Mason LSP installer integration
{
    "mason-org/mason-lspconfig.nvim",
    dependencies = {"mason-org/mason.nvim", "neovim/nvim-lspconfig"},
    config = function()
        require("mason-lspconfig").setup({
            ensure_installed = {"pyright", "ruff"},
            automatic_installation = true
        })
    end
}, -- LSP Configs for each language server
{
    "neovim/nvim-lspconfig",
    opts = {
        servers = {
            ruff = {
                init_options = {
                    interpreter = {
                        path = python_path
                    }
                }
            }
        }
    },
    config = function()
        -- Configure Pyright
        require("lspconfig").pyright.setup({
            settings = {
                python = {
                    pythonPath = python_path
                }
            },
            env = {
                PYTHONPATH = python_path
            }
        })

        -- Configure Ruff LSP
        require("lspconfig").ruff.setup({
            init_options = {
                settings = {
                    pythonPath = python_path
                }
            }
        })
    end
}}
