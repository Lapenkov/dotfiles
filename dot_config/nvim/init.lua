function configure_indent ()
    vim.o.expandtab = true
    vim.o.tabstop = 4
    vim.o.shiftwidth = 4
end

function configure_search ()
    vim.o.ignorecase = true
    vim.o.smartcase = true
end

configure_indent()
configure_search()
vim.o.number = true
