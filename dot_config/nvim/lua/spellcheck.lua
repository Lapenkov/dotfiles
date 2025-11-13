local M = {}

function M.configure()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "text", "gitcommit" },
    command = "setlocal spell",
  })
end

return M
