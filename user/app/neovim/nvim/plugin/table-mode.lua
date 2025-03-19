-- Table mode configuration
vim.g.table_mode_corner = '|'
vim.g.table_mode_header_fillchar = '-'

-- Keymaps for table mode with standardized <leader>m prefix
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.keymap.set('n', '<leader>mt', ':TableModeToggle<CR>', {
      buffer = true,
      silent = true,
      desc = "Toggle table mode"
    })
    vim.keymap.set('n', '<leader>mr', ':TableModeRealign<CR>', {
      buffer = true,
      silent = true,
      desc = "Realign table"
    })
  end
})
