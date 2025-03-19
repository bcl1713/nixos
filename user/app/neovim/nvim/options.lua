-- user/app/neovim/lua/options.lua

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.clipboard = 'unnamedplus'

vim.o.number = true
vim.o.relativenumber = true

vim.o.signcolumn = 'yes'

vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.smartindent = true

vim.o.updatetime = 300

vim.o.termguicolors = true

vim.o.mouse = 'a'

vim.o.conceallevel = 2

-- Global format options
vim.o.formatoptions = 'tcqjrn1'

-- Format options to improve default behavior
vim.opt.formatoptions:append("j") -- Remove comment leader when joining lines
vim.opt.formatoptions:remove("o") -- Don't insert comment leader on 'o' or 'O'

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = "nc"
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
    vim.opt_local.textwidth = 80

    vim.keymap.set('n', 'j', 'gj', { buffer = true })
    vim.keymap.set('n', 'k', 'gk', { buffer = true })
  end
})
