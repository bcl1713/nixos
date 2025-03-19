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
