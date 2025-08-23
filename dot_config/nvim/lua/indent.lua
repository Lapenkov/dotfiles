local M = {}

function M.configure()
    vim.o.expandtab = true
    vim.o.tabstop = 4
    vim.o.shiftwidth = 4
    vim.o.cindent = true
    -- Don't indent inside namespaces
    vim.opt.cinoptions:append("N-s")
    -- Half-indent scope modifiers (i.e. private, public, protected)
    vim.opt.cinoptions:append("g-0.5s")
end

return M
