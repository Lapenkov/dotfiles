return {
  "nvim-treesitter/nvim-treesitter",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "c",
        "cpp",
        "python",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "json",
        "xml",
        "toml",
        "yaml",
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
          init_selection = "<cr>",
          scope_incremental = "<cr>",
          node_incremental = "<TAB>",
          node_decremental = "<S-TAB>",
        },
      },
      indent = {
        enable = true,
        disable = { "c", "cpp" },
      },
    })
  end,
}
