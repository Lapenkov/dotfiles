function configure_commands()
    -- Custom commands start with L (short for lapenkoa)

    vim.api.nvim_create_user_command("LOpenPwd",
        function(opts)
            vim.cmd.Neotree()
            vim.cmd.wincmd("l")
            require("telescope.builtin").find_files()
        end,
        {})
end

function configure_nonpkg_mappings()
    vim.g.mapleader = " "
    vim.keymap.set("n", "<leader>n", "<cmd>nohlsearch<cr>")
    vim.keymap.set("n", "]c", "<cmd>cnext<cr>")
    vim.keymap.set("n", "]C", "<cmd>cprev<cr>")
end

function configure_indent()
    vim.o.expandtab = true
    vim.o.tabstop = 4
    vim.o.shiftwidth = 4
end

function configure_search()
    vim.o.ignorecase = true
    vim.o.smartcase = true
end

function configure_mouse()
    vim.o.mouse = ""
end

function configure_pkg()
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
        vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable",
            lazypath,
        })
    end
    vim.opt.rtp:prepend(lazypath)

    require("lazy").setup({
        {
            "nvim-neo-tree/neo-tree.nvim",
            lazy = false,
            branch = "v3.x",
            dependencies = {
                "nvim-lua/plenary.nvim",
                "nvim-tree/nvim-web-devicons",
                "MunifTanjim/nui.nvim",
            },
            keys = {
                { "<leader>tt", "<cmd>Neotree focus<cr>" },
                { "<leader>tf", "<cmd>Neotree reveal reveal_force_cwd<cr>" },
                { "<leader>tc", "<cmd>Neotree close<cr>" },
            },
            config = function()
                require("neo-tree").setup({
                    filesystem = {
                        window = {
                            mappings = {
                                ["u"] = "navigate_up",
                            },
                        },
                    },
                })
            end
        },
        {
            -- Theme; colorscheme
            "folke/tokyonight.nvim",
            lazy = false,
            config = function()
                require("tokyonight").setup({
                    style = "moon",
                    light_style = "day",
                    vim.cmd("color tokyonight-storm")
                })
            end
        },
        {
            "nvim-telescope/telescope.nvim",
            branch = "0.1.x",
            dependencies = {
                "nvim-lua/plenary.nvim",
                { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
            },
            keys = {
                { "<leader>ff", "<cmd>Telescope find_files --hidden=true<cr>" },
                { "<leader>fc", "<cmd>Telescope find_files --hidden=false<cr>" },
                { "<leader>fb",
                    function(plugin)
                        require('telescope.builtin').buffers({ sort_lastused = true, ignore_current_buffer = true })
                    end,
                },
                { "<leader>fG", "<cmd>Telescope live_grep<cr>" },
                { "<leader>fg", "<cmd>Telescope live_grep --type=cpp<cr>" },
                { "<leader>fp", "<cmd>Telescope live_grep --type=py<cr>" },
                { "<leader>fs", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>" },
            },
            config = function()
                local telescope = require("telescope")
                local actions = require("telescope.actions")

                telescope.setup({
                    defaults = {
                        mappings = {
                            i = {
                                ["<C-j>"] = actions.move_selection_next,
                                ["<C-k>"] = actions.move_selection_previous,
                                ["<C-n>"] = actions.cycle_history_next,
                                ["<C-p>"] = actions.cycle_history_prev,
                                ["<C-d>"] = actions.delete_buffer,
                            },
                        },
                    },
                    extensions = {
                        fzf = {
                            fuzzy = true,
                            override_generic_sorter = true,
                            override_file_sorter = true,
                            case_mode = "smart_case",
                        }
                    },
                })
            end
        },
        {
            "nvim-treesitter/nvim-treesitter",
            config = function()
                require("nvim-treesitter.configs").setup({
                    ensure_installed = {
                        "c", "cpp", "python", "lua",
                        "vim", "vimdoc", "query",
                        "json", "xml", "toml", "yaml",
                    },
                    sync_install = true,
                    auto_install = true,
                    highlight = {
                        enable = true,
                        additional_vim_regex_highlighting = false,
                    },
                    incremental_selection = {
                        enable = true,
                        keymaps = {
                            init_selection = '<cr>',
                            scope_incremental = '<cr>',
                            node_incremental = '<TAB>',
                            node_decremental = '<S-TAB>',
                        },
                    },
                })
            end,
        },
        {
            "NeogitOrg/neogit",
            dependencies = {
                "nvim-lua/plenary.nvim",
                "nvim-telescope/telescope.nvim",
                "sindrets/diffview.nvim",
            },
            config = true,
        },
        {
            "tpope/vim-fugitive",
            lazy = false,
            keys = {
                { "<leader>tb", "<cmd>Git blame<cr>" },
            },
        },
        {
            "neovim/nvim-lspconfig",
            config = function()
                local lspconfig = require("lspconfig")
                lspconfig.pylsp.setup {
                    settings = {
                        pylsp = {
                            plugins = {
                                black = { enabled = true },
                                yapf = { enabled = false },
                            },
                        },
                    },
                }
                lspconfig.clangd.setup({
                    cmd = {
                        "/ctc/users/lapenkoa/conan_data/llvm-project/18.1.1/tools/opt/package/951857a798b4abc157d26eafae83b3d683f8ede1/bin/clangd",
                        "--header-insertion=never",
                        "--background-index=false",
                        "--header-insertion-decorators",
                        "--enable-config",
                        "--offset-encoding=utf-16",
                        "--malloc-trim",
                        "--pch-storage=disk"
                    },
                })

                vim.api.nvim_create_autocmd("LspAttach", {
                    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                    callback = function(ev)
                        local opts = { buffer = ev.buf }
                        vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, opts)
                        vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)
                        vim.keymap.set("n", "<leader>gt", vim.lsp.buf.type_definition, opts)
                        vim.keymap.set("n", "<leader>gr", require('telescope.builtin').lsp_references, opts)
                        vim.keymap.set("n", "<leader>gc", require('telescope.builtin').lsp_incoming_calls, opts)
                        vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, opts)
                        vim.keymap.set("n", "<leader>cf", function() vim.lsp.buf.code_action { apply = true } end, opts)
                        vim.keymap.set("n", "<leader>ee", vim.diagnostic.open_float, opts)
                        vim.keymap.set({ "n", "v" }, "<leader>cc", vim.lsp.buf.format, opts)
                        vim.keymap.set("n", "<leader>gh", "<cmd>ClangdSwitchSourceHeader<cr>")
                        vim.keymap.set("n", "<leader>ci", vim.lsp.buf.hover, opts)
                        vim.keymap.set("n", "]e", vim.diagnostic.goto_next, opts)
                        vim.keymap.set("n", "]E", vim.diagnostic.goto_prev, opts)
                    end
                })
            end
        },
        {
            "github/copilot.vim"
        },
    })
end

function configure()
    vim.o.number = true
    vim.o.wrap = true
    vim.o.wildoptions = "fuzzy,pum,tagfile"
    vim.o.wildmode = "full"
    vim.o.matchpairs =  vim.o.matchpairs .. ",<:>"

    configure_commands()
    configure_nonpkg_mappings()
    configure_indent()
    configure_search()
    configure_mouse()
    configure_pkg()
end

configure()
