function configure_commands()
    -- Custom commands start with L (short for lapenkoa)

    vim.api.nvim_create_user_command("LOpenPwd", function(opts)
        -- Schedule to execute in the main loop; after Telescope initializes
        vim.schedule(function(opts)
            require("telescope.builtin").find_files({})
        end)
    end, {})
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
    vim.o.cindent = true
    -- Don't indent inside namespaces
    vim.opt.cinoptions:append("N-s")
    -- Half-indent scope modifiers (i.e. private, public, protected)
    vim.opt.cinoptions:append("g-0.5s")
end

function configure_search()
    vim.o.ignorecase = true
    vim.o.smartcase = true
    vim.o.grepprg = "rg --vimgrep --no-heading --smart-case"
    vim.o.grepformat = "%f:%l:%c:%m"
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
            "stevearc/oil.nvim",
            opts = {
                skip_confirm_for_simple_edits = false,
                watch_for_changes = true,
            },
            dependencies = { { "nvim-web-devicons", opts = {} } },
            lazy = false,
            keys = {
                { "-", "<cmd>Oil --float<cr>" },
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
                { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
            },
            keys = {
                {
                    "<leader>ff",
                    function()
                        require('telescope.builtin').find_files {
                            hidden = false,
                            follow = false,
                        }
                    end,
                    desc = "Find fildes (only non-hidden ones)",
                },
                {
                    "<leader>fF",
                    function()
                        require('telescope.builtin').find_files {
                            hidden = true,
                            follow = true,
                        }
                    end,
                    desc = "Find fildes (including hidden ones)",
                },
                {
                    "<leader>fh",
                    function()
                        require('telescope.builtin').help_tags()
                    end,
                    desc = "Search help tags",
                },
                {
                    "<leader>fb",
                    function(plugin)
                        require('telescope.builtin').buffers({ sort_mru = true, ignore_current_buffer = true })
                    end,
                    desc = "Search buffers",
                },
                { "<leader>fG", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
                {
                    "<leader>fg", 
                    function()
                        require('telescope.builtin').live_grep {
                            -- Here we pass FZF args
                            additional_args = {"--hidden", "--glob", "!{**/.git/*, **/tags}"},
                        }
                    end,
                    desc = "Live grep with hidden files",
                },
                {
                    "<leader>fp",
                    function()
                        require('telescope.builtin').live_grep {
                            additional_args = {"--hidden", "--glob", "!{**/.git/*, **/tags}", "--type", "python"},
                        }
                    end,
                    desc = "Live grep Python files",
                },
                { "<leader>fs", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Search symbols" },
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
            "tpope/vim-fugitive",
            lazy = false,
            keys = {
                { "<leader>tb", "<cmd>Git blame<cr>", desc = "Toggle blame" },
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
                        "--background-index=false",
                        "--header-insertion=never",
                        "--enable-config",
                        "--offset-encoding=utf-16",
                        "--malloc-trim",
                        "--pch-storage=disk"
                    },
                })
                lspconfig.lua_ls.setup {}

                vim.api.nvim_create_autocmd("LspAttach", {
                    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                    callback = function(ev)
                        local opts = { buffer = ev.buf }
                        local buf_ft = vim.api.nvim_buf_get_option(ev.buf, "filetype")
                        if buf_ft == "bzl" then
                            -- For Bazel, we don't have an Lsp other than Copilot. Don't map.
                            return
                        end
                        vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, opts)
                        vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)
                        vim.keymap.set("n", "<leader>gt", vim.lsp.buf.type_definition, opts)
                        vim.keymap.set("n", "<leader>gr", require('telescope.builtin').lsp_references, opts)
                        vim.keymap.set("n", "<leader>gc", require('telescope.builtin').lsp_incoming_calls, opts)
                        vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, opts)
                        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
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
        {
            "yarospace/lua-console.nvim",
            keys = {
                { "`", desc = "Lua-console - toggle" },
                { "<leader>`", desc = "Lua-console - attach to buffer" },
            },
            opts = {},
        },
        {
            "szw/vim-maximizer",
            keys = {
                { "<leader>sm", "<cmd>MaximizerToggle<cr>", desc = "Maximize/minimze split" },
            }
        },
    })
end

function configure_buildifier()
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "bzl",
        callback = function(event)
            vim.keymap.set(
                "n", "<leader>cc",
                function()
                    vim.cmd(':w')
                    local buildifier_cmd = vim.fn.expand("$HOME") .. "/go/bin/buildifier"
                    local current_buffer_path = vim.api.nvim_buf_get_name(0)
                    local res = vim.system({ buildifier_cmd, current_buffer_path }, { text = true }):wait()
                    if res.code ~= 0 then
                        local stderr_out = res.stderr or ""
                        vim.api.nvim_echo({
                            { "Buildifier failed with error code " .. res.code .. ".", "ErrorMsg" },
                            { "\nStderr: " .. stderr_out, "ErrorMsg" }
                        }, true, {})
                    else
                        vim.api.nvim_echo({{ "Successfully applied buildifier", "Normal" }}, false, {})
                        vim.cmd("checktime") -- Reload the buffer, since its timestamp has changed
                    end
                end,
                { silent = true, buffer = event.buf, desc = "Apply buildifier to the current buffer" }
            )
        end,
    })
end

function configure_spellcheck()
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "text", "gitcommit" },
        command = "setlocal spell",
    })
end

-- TODO:
-- Lua formatting / linting
-- Multi-file config

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
    configure_buildifier()
    configure_spellcheck()
end

configure()
