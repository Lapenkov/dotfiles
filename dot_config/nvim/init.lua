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

function configure_clipboard()
    local powershell_path = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
    local clip_path = "/mnt/c/Windows/System32/clip.exe"
    vim.g.clipboard = {
        name = "WSL",
        copy = {
            ["+"] = clip_path,
            ["*"] = clip_path,
        },
        paste = {
            ["+"] = powershell_path .. ' -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
            ["*"] = powershell_path .. ' -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
        },
        cache_enabled = true
    }
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
                { "<leader>fb", "<cmd>Telescope buffers<cr>" },
                { "<leader>fG", "<cmd>Telescope live_grep<cr>" },
                { "<leader>fg", "<cmd>Telescope live_grep --type=cpp<cr>" },
                { "<leader>fp", "<cmd>Telescope live_grep --type=py<cr>" },
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
                                ["<C-d>"] = actions.delete_buffer + actions.move_to_top,
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
            "FabijanZulj/blame.nvim",
            keys = {
                { "<leader>tb", "<cmd>ToggleBlame<cr>" },
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
                        "clangd",
                        "--header-insertion=never",
                        "--background-index",
                        "--header-insertion-decorators",
                        "--enable-config",
                    },
                })

                vim.api.nvim_create_autocmd("LspAttach", {
                    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                    callback = function(ev)
                        local opts = { buffer = ev.buf }
                        vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, opts)
                        vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)
                        vim.keymap.set("n", "<leader>gt", vim.lsp.buf.type_definition, opts)
                        vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opts)
                        vim.keymap.set("n", "<leader>cf", vim.lsp.buf.code_action, opts)
                        vim.keymap.set("n", "<leader>ee", vim.diagnostic.open_float, opts)
                        vim.keymap.set({ "n", "v" }, "<leader>cc", vim.lsp.buf.format, opts)
                        vim.keymap.set({ "n", "i" }, "<C-k>", vim.lsp.buf.signature_help, opts)
                        vim.keymap.set("n", "<leader>gh", "<cmd>ClangdSwitchSourceHeader<cr>")
                    end
                })
            end
        }
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
    configure_clipboard()
    configure_mouse()
    configure_pkg()
end

configure()
