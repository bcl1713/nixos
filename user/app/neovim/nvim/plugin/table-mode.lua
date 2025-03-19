-- Table mode configuration
vim.g.table_mode_corner = '|'
vim.g.table_mode_header_fillchar = '-'

-- Keymaps for table mode
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.keymap.set('n', '<leader>tm', ':TableModeToggle<CR>', { buffer = true, silent = true })
    vim.keymap.set('n', '<leader>tr', ':TableModeRealign<CR>', { buffer = true, silent = true })
  end
})
