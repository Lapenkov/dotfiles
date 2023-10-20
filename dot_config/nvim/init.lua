function configure_commands()
    -- Custom commands start with L (short for lapenkoa)

    vim.api.nvim_create_user_command('LOpenPwd',
        function(opts)
            vim.cmd.Neotree()
        end,
        {})
end

function configure_nonpkg_mappings()
    vim.g.mapleader = " "
    vim.keymap.set("n", "<Leader>n", "<cmd>nohlsearch<cr>")
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
            branch = "v3.x",
            dependencies = {
                "nvim-lua/plenary.nvim",
                "nvim-tree/nvim-web-devicons",
                "MunifTanjim/nui.nvim",
            },
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
                "nvim-telescope/telescope-live-grep-args.nvim",
            },
            config = function()
                local telescope = require("telescope")
                local lga_actions = require("telescope-live-grep-args.actions")

                telescope.setup({
                    pickers = {
                        find_files = {
                            hidden = true,
                        },
                    },
                    extensions = {
                        live_grep_args = {
                            auto_quoting = true,
                            mappings = {
                                i = {
                                    ["<C-k>"] = lga_actions.quote_prompt(),
                                    ["<C-b>"] = lga_actions.quote_prompt({ postfix = " --type bazel " }),
                                    ["<C-b>"] = lga_actions.quote_prompt({ postfix = " --hidden " }),
                                    ["<C-t>"] = lga_actions.quote_prompt({ postfix = " --iglob !**/test* " }),
                                },
                            },
                        },
                    },
                })

                telescope.load_extension("live_grep_args")
            end
        },
        {
            "nvim-treesitter/nvim-treesitter",
            config = function()
                require("nvim-treesitter.configs").setup({
                    ensure_installed = { "c", "cpp", "python", "yaml", "lua", "vim", "vimdoc", "query", "json" },
                    sync_install = true,
                    auto_install = true,
                    highlight = {
                        enable = true,
                        additional_vim_regex_highlighting = false,
                    },
                    incremental_selection = {
                        enable = true,
                        keymaps = {
                            init_selection = '<CR>',
                            scope_incremental = '<CR>',
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
        },
        {
            "neovim/nvim-lspconfig",
            config = function()
                local lspconfig = require("lspconfig")
                lspconfig.pylsp.setup {}
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
                        vim.keymap.set({ "n", "v" }, "<leader>cc", vim.lsp.buf.format, opts)
                        vim.keymap.set({ "n", "i" }, "<C-k>", vim.lsp.buf.signature_help, opts)
                    end
                })
            end
        }
    })

    vim.keymap.set("n", "<Leader>ff", "<cmd>Telescope find_files<cr>")
    vim.keymap.set("n", "<Leader>fb", "<cmd>Telescope buffers<cr>")
    vim.keymap.set("n", "<leader>fg", "<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<cr>")
    vim.keymap.set("n", "<Leader>fp", "<cmd>Telescope live_grep glob_pattern=*.py<cr>")
    vim.keymap.set("n", "<Leader>tt", "<cmd>Neotree focus<cr>")
    vim.keymap.set("n", "<Leader>tf", "<cmd>Neotree reveal reveal_force_cwd<cr>")
    vim.keymap.set("n", "<Leader>tc", "<cmd>Neotree close<cr>")
end

function configure()
    vim.o.number = true
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
