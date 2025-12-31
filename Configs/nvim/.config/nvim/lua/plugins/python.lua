return {

    { import = "lazyvim.plugins.extras.lang.python" },

    -- {
    --     ---@module 'python'
    --     {
    --         "joshzcold/python.nvim",
    --         ---@type python.Config
    --         opts = { ---@diagnostic disable-line: missing-fields`
    --         }
    --     }
    -- },

    {
        "mfussenegger/nvim-dap-python",
        -- stylua: ignore
        keys = {
            { "<leader>dPt", function() require('dap-python').test_method() end, desc = "Debug Method", ft = "python" },
            { "<leader>dPc", function() require('dap-python').test_class() end,  desc = "Debug Class",  ft = "python" },
        },
        config = function()
            if vim.fn.has("win32") == 1 then
                require("dap-python").setup(LazyVim.get_pkg_path("debugpy", "~/.venv/Scripts/pythonw.exe"))
            else
                -- require("dap-python").setup("uv")
                require("dap-python").setup("~/.venv/bin/python")
            end
        end,
        dependencies = {
            "mfussenegger/nvim-dap",
        },
    },
    {
        "rcarriga/nvim-dap-ui",
        config = function()
            -- Setup dapui
            local dapui = require("dapui")

            -- Configure dapui to open when DAP session is initialized
            require("dap").listeners.after["event_initialized"]["dapui_config"] = function()
                dapui.open()
            end

            -- Configure dapui to close when DAP session ends
            require("dap").listeners.before["event_terminated"]["dapui_config"] = function()
                dapui.close()
            end
            require("dap").listeners.before["event_exited"]["dapui_config"] = function()
                dapui.close()
            end
        end,
        keys = {
            -- Toggle DAP UI
            {
                "<leader>du",
                function()
                    require("dapui").toggle({})
                end,
                desc = "Dap UI"
            },
            -- Start Debug Session (F5 or <leader>dc)
            {
                "<leader>dc",
                function()
                    require("dap").continue()
                end,
                desc = "Start/Continue Debug Session"
            },
            -- Toggle Breakpoint
            {
                "<leader>db",
                function()
                    require("dap").toggle_breakpoint()
                end,
                desc = "Toggle Breakpoint"
            },
            -- Toggle Conditional Breakpoint
            {
                "<leader>dB",
                function()
                    local condition = vim.fn.input("Breakpoint Condition: ") -- Prompt for the condition
                    require("dap").set_breakpoint(condition)                 -- Set the breakpoint with the condition
                end,
                desc = "Toggle Conditional Breakpoint"
            },

            -- Step Forward
            {
                "<leader>ds",
                function()
                    require("dap").step_over()
                end,
                desc = "Step Over"
            },
            -- Step Into
            {
                "<leader>dn",
                function()
                    require("dap").step_into()
                end,
                desc = "Step Into"
            },
            -- Step Out
            {
                "<leader>dn",
                function()
                    require("dap").step_out()
                end,
                desc = "Step Out"
            },
        },
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
            "jay-babu/mason-nvim-dap.nvim",
            "leoluz/nvim-dap-go",
            "mfussenegger/nvim-dap-python",
            "theHamsta/nvim-dap-virtual-text",
        },
    }
}
