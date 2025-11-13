return {
  -- Theme; colorscheme
  "folke/tokyonight.nvim",
  lazy = false,
  config = function()
    require("tokyonight").setup({
      style = "moon",
      light_style = "day",
      vim.cmd("color tokyonight-storm"),
    })
  end,
}
