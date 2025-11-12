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
                    indent = {
                        enable = true,
                        disable = { "c", "cpp" },
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
            dependencies = { "hrsh7th/cmp-nvim-lsp" },
            config = function()
                local capabilities = require("cmp_nvim_lsp").default_capabilities()

                vim.lsp.config("pylsp", {
                    capabilities = capabilities,
                    settings = {
                        ["pylsp"] = {
                            plugins = {
                                black = { enabled = true },
                                yapf = { enabled = false },
                                pylint = { enabled = true, executable = "pylint" },
                                jedi_completion = { fuzzy = true },
                            },
                        },
                    },
                })
                vim.lsp.enable("pylsp")

                vim.lsp.config("clangd", {
                    capabilities = capabilities,
                    cmd = {
                        "clangd",
                        "--background-index=false",
                        "--header-insertion=never",
                        "--enable-config",
                        "--offset-encoding=utf-16",
                        "--all-scopes-completion",
                        "--completion-style=detailed",
                        "--function-arg-placeholders=true",
                        "--malloc-trim",
                        "--pch-storage=disk"
                    },
                })
                vim.lsp.enable("clangd")

                vim.lsp.config("lua_lsp", {
                    capabilities = capabilities,
                })
                vim.lsp.enable("lua_lsp")

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
                        vim.keymap.set("n", "<leader>gh", function()
                                for _, win in pairs(vim.api.nvim_list_wins()) do
                                    local config = vim.api.nvim_win_get_config(win)
                                    if config.relative ~= '' then
                                        vim.api.nvim_win_close(win, true)
                                    end
                                end
                                vim.cmd("LspClangdSwitchSourceHeader")
                            end,
                            opts)
                        vim.keymap.set("n", "<leader>ci", vim.lsp.buf.hover, opts)
                        vim.keymap.set("n", "]e", vim.diagnostic.goto_next, opts)
                        vim.keymap.set("n", "]E", vim.diagnostic.goto_prev, opts)
                    end
                })
            end
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
        {
            "L3MON4D3/LuaSnip",
            version = "v2.*",
            dependencies = { "rafamadriz/friendly-snippets" },
            opts = {
                log_level = "info",
            },
        },
        {
            "hrsh7th/nvim-cmp",
            dependencies = {
                "L3MON4D3/LuaSnip",
                "hrsh7th/cmp-buffer",
                "hrsh7th/cmp-path",
                "hrsh7th/cmp-cmdline",
                "saadparwaiz1/cmp_luasnip",
            },
            config = function()
                local cmp = require("cmp")
                local luasnip = require("luasnip")

                cmp.setup({
                    snippet = {
                        expand = function(args)
                            luasnip.lsp_expand(args.body)
                        end
                    },
                    mapping = cmp.mapping.preset.insert({
                        ['<C-p>'] = cmp.mapping.scroll_docs(-4),
                        ['<C-n>'] = cmp.mapping.scroll_docs(4),
                        ['<C-Space>'] = cmp.mapping.complete(),
                        ['<C-e>'] = cmp.mapping.abort(),
                        ['<CR>'] = cmp.mapping(function(fallback)
                            if cmp.visible() then
                                if luasnip.expandable() then
                                    luasnip.expand()
                                else
                                    cmp.confirm({
                                        select = true,
                                    })
                                end
                            else
                                fallback()
                            end
                        end),

                        ["<Tab>"] = cmp.mapping(function(fallback)
                            if cmp.visible() then
                                cmp.select_next_item()
                            elseif luasnip.locally_jumpable(1) then
                                luasnip.jump(1)
                            else
                                fallback()
                            end
                        end, { "i", "s" }),

                        ["<S-Tab>"] = cmp.mapping(function(fallback)
                            if cmp.visible() then
                                cmp.select_prev_item()
                            elseif luasnip.locally_jumpable(-1) then
                                luasnip.jump(-1)
                            else
                                fallback()
                            end
                        end, { "i", "s" }),
                    }),
                    sources = cmp.config.sources({
                        { name = 'path' },
                        { name = 'nvim_lsp', keyword_length = 1 },
                        { name = 'buffer', keyword_length = 3 },
                        { name = 'luasnip', keyword_length = 2 },
                    }),
                    window = {
                        documentation = cmp.config.window.bordered(),
                        completion = cmp.config.window.bordered({
                            winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,Search:None',
                            col_offset = -3,
                            side_padding = 0,
                        }),
                    },
                    formatting = {
                        fields = {'menu', 'abbr', 'kind'},
                        format = function(entry, item)
                            local menu_icon = {
                                nvim_lsp = 'λ',
                                luasnip = '⋗',
                                buffer = '𝚻',
                                path = '🖫',
                            }

                            item.menu = menu_icon[entry.source.name]
                            local compl_item = entry:get_completion_item()
                            if compl_item.detail then
                                if item.kind == 'Method' then
                                    item.kind = item.kind .. ' ->'
                                end
                                item.kind = item.kind .. ' [' .. (compl_item.detail) .. ']'
                            end
                            return item
                        end,
                    },
                    experimental = {
                        ghost_text = true,
                    },
                })

                cmp.setup.cmdline({ '/', '?' }, {
                    mapping = cmp.mapping.preset.cmdline(),
                    sources = {
                        { name = 'buffer' }
                    }
                })

                cmp.setup.cmdline(':', {
                    mapping = cmp.mapping.preset.cmdline(),
                    sources = cmp.config.sources({
                        { name = 'path' }
                    }, {
                        { name = 'cmdline' }
                    }),
                    matching = { disallow_symbol_nonprefix_matching = false }
                })
            end
        },
    })
end

-- TODO:
-- Lua formatting / linting

function configure()
    vim.o.number = true
    vim.o.wrap = true
    vim.o.wildoptions = "fuzzy,pum,tagfile"
    vim.o.wildmode = "full"
    vim.o.matchpairs =  vim.o.matchpairs .. ",<:>"

    require("commands").configure()
    require("nonpkg_mappings").configure()
    require("indent").configure()
    require("search").configure()
    require("mouse").configure()
    require("buildifier").configure()
    require("spellcheck").configure()

    configure_pkg()
end

configure()
