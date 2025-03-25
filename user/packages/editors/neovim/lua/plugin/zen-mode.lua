require("zen-mode").setup {
  window = {
    width = 90,
    options = {
      number = false,
      relativenumber = false,
      signcolumn = "no",
      cursorline = false,
    }
  },
  plugins = {
    gitsigns = { enabled = false },
  }
}

-- Add keymapping for zen mode
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.keymap.set('n', '<leader>mz', ':ZenMode<CR>', {
      buffer = true,
      silent = true,
      desc = "Toggle Zen mode"
    })
  end
})
