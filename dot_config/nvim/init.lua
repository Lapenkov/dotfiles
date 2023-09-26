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
            -- Theme
            "nyoom-engineering/oxocarbon.nvim",
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
                                    ["<C-p>"] = lga_actions.quote_prompt({ postfix = " --type python " }),
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
                    enable = true,
                    ensure_installed = { "c", "cpp", "python", "yaml", "lua", "vim", "vimdoc", "query", "json" },
                    sync_install = true,
                    auto_install = true,
                    additional_vim_regex_highlighting = false,
                })
            end,
        },
    })

    vim.keymap.set("n", "<Leader>ff", "<cmd>Telescope find_files<cr>")
    vim.keymap.set("n", "<leader>fg", "<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<cr>")
    vim.keymap.set("n", "<Leader>fp", "<cmd>Telescope live_grep glob_pattern=*.py<cr>")
    vim.keymap.set("n", "<Leader>tt", "<cmd>Neotree focus<cr>")
    vim.keymap.set("n", "<Leader>tf", "<cmd>Neotree reveal<cr>")
    vim.keymap.set("n", "<Leader>tc", "<cmd>Neotree close<cr>")
end

function configure()
    configure_commands()
    configure_nonpkg_mappings()
    configure_indent()
    configure_search()
    configure_clipboard()
    configure_mouse()
    configure_pkg()

    vim.o.number = true
    vim.o.wildoptions = "fuzzy,pum,tagfile"
    vim.o.wildmode = "full"
end

configure()
