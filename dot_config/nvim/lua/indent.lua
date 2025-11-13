local M = {}

function M.configure()
  vim.opt.expandtab = true
  vim.opt.tabstop = 4
  vim.opt.shiftwidth = 4
  vim.opt.cindent = true
  -- Don't indent inside namespaces
  vim.opt.cinoptions:append("N-s")
  -- Half-indent scope modifiers (i.e. private, public, protected)
  vim.opt.cinoptions:append("g-0.5s")
end

return M
