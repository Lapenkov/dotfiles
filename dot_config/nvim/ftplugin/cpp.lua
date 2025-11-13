vim.opt_local.expandtab = true
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.cindent = true
-- Don't indent inside namespaces
vim.opt_local.cinoptions:append("N-s")
-- Half-indent scope modifiers (i.e. private, public, protected)
vim.opt_local.cinoptions:append("g-0.5s")
