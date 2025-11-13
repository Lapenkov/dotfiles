local M = {}

function M.configure()
  vim.g.mapleader = " "
  vim.keymap.set("n", "<leader>n", "<cmd>nohlsearch<cr>")
  vim.keymap.set("n", "]c", "<cmd>cnext<cr>")
  vim.keymap.set("n", "]C", "<cmd>cprev<cr>")
end

return M
