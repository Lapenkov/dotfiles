return {
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
}
