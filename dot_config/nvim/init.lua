function configure_pkg()
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable",
      lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)

  require("lazy").setup("plugins")
end

-- TODO:
-- Lua formatting / linting

function configure()
  vim.o.number = true
  vim.o.wrap = true
  vim.o.wildoptions = "fuzzy,pum,tagfile"
  vim.o.wildmode = "full"
  vim.o.matchpairs = vim.o.matchpairs .. ",<:>"

  require("commands").configure()
  require("nonpkg_mappings").configure()
  require("indent").configure()
  require("search").configure()
  require("mouse").configure()
  require("spellcheck").configure()

  configure_pkg()
end

configure()
