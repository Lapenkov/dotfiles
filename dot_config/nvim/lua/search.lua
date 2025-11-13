local M = {}

function M.configure()
  vim.o.ignorecase = true
  vim.o.smartcase = true
  vim.o.grepprg = "rg --vimgrep --no-heading --smart-case"
  vim.o.grepformat = "%f:%l:%c:%m"
end

return M
