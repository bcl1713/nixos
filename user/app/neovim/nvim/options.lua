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

    vim.keymap.set('n', 'j', 'gj', {
      buffer = true,
      desc = "Down (visual line)"
    })
    vim.keymap.set('n', 'k', 'gk', {
      buffer = true,
      desc = "Up (visual line)"
    })
  end
})

-- Basic editor shortcuts with standardized prefixes
vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = "Save file" })
vim.keymap.set('n', '<leader>q', ':q<CR>', { desc = "Quit" })
vim.keymap.set('n', '<leader>Q', ':qa!<CR>', { desc = "Force quit all" })

-- Window management with <leader>w prefix
vim.keymap.set('n', '<leader>wh', '<C-w>h', { desc = "Move to left window" })
vim.keymap.set('n', '<leader>wj', '<C-w>j', { desc = "Move to bottom window" })
vim.keymap.set('n', '<leader>wk', '<C-w>k', { desc = "Move to top window" })
vim.keymap.set('n', '<leader>wl', '<C-w>l', { desc = "Move to right window" })
vim.keymap.set('n', '<leader>ws', '<C-w>s', { desc = "Split window horizontally" })
vim.keymap.set('n', '<leader>wv', '<C-w>v', { desc = "Split window vertically" })
vim.keymap.set('n', '<leader>wq', '<C-w>q', { desc = "Close window" })
vim.keymap.set('n', '<leader>w=', '<C-w>=', { desc = "Equal window width" })

-- Also keep the Ctrl+hjkl window navigation for quick movement
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = "Move to left window" })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = "Move to bottom window" })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = "Move to top window" })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = "Move to right window" })

-- Resize with arrows
vim.keymap.set('n', '<C-Up>', ':resize -2<CR>', { desc = "Resize window up" })
vim.keymap.set('n', '<C-Down>', ':resize +2<CR>', { desc = "Resize window down" })
vim.keymap.set('n', '<C-Left>', ':vertical resize -2<CR>', { desc = "Resize window left" })
vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', { desc = "Resize window right" })

-- Buffer operations with <leader>b prefix
vim.keymap.set('n', '<leader>bn', ':bnext<CR>', { desc = "Next buffer" })
vim.keymap.set('n', '<leader>bp', ':bprevious<CR>', { desc = "Previous buffer" })
vim.keymap.set('n', '<leader>bd', ':bd<CR>', { desc = "Delete buffer" })
vim.keymap.set('n', '<leader>bl', ':buffers<CR>', { desc = "List buffers" })

-- Also keep Shift+hl for quick buffer navigation
vim.keymap.set('n', '<S-l>', ':bnext<CR>', { desc = "Next buffer" })
vim.keymap.set('n', '<S-h>', ':bprevious<CR>', { desc = "Previous buffer" })

-- Stay in indent mode
vim.keymap.set('v', '<', '<gv', { desc = "Indent left and stay in visual mode" })
vim.keymap.set('v', '>', '>gv', { desc = "Indent right and stay in visual mode" })

-- Move text up and down
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { desc = "Move text down" })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { desc = "Move text up" })

-- Clear search highlighting
vim.keymap.set('n', '<Esc>', ':noh<CR>', { desc = "Clear search highlighting" })

-- Maintain cursor position when joining lines
vim.keymap.set('n', 'J', 'mzJ`z', { desc = "Join lines (maintain cursor position)" })

-- Keep cursor centered when paging
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = "Move down half a page (centered)" })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = "Move up half a page (centered)" })

-- Keep search terms centered
vim.keymap.set('n', 'n', 'nzzzv', { desc = "Next search result (centered)" })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = "Previous search result (centered)" })

-- Clipboard operations
vim.keymap.set('n', '<leader>y', '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set('v', '<leader>y', '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set('n', '<leader>Y', '"+Y', { desc = "Yank line to system clipboard" })
vim.keymap.set('x', '<leader>p', '"_dP', { desc = "Paste without overwriting register" })

-- Quickfix navigation
vim.keymap.set('n', '<leader>cn', ':cnext<CR>', { desc = "Next quickfix item" })
vim.keymap.set('n', '<leader>cp', ':cprev<CR>', { desc = "Previous quickfix item" })
vim.keymap.set('n', '<leader>co', ':copen<CR>', { desc = "Open quickfix list" })
vim.keymap.set('n', '<leader>cc', ':cclose<CR>', { desc = "Close quickfix list" })
