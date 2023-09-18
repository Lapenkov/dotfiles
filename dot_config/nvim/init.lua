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
            }
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
end

function configure()
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
