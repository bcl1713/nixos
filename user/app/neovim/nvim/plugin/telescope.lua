require('telescope').setup({
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
      -- the default case_mode is "smart_case"
    }
  }
})

local telescope_builtin = require('telescope.builtin')

-- File navigation with <leader>f prefix
vim.keymap.set('n', '<leader>ff', telescope_builtin.find_files, { desc = "Find files" })
vim.keymap.set('n', '<leader>fg', telescope_builtin.live_grep, { desc = "Find text" })
vim.keymap.set('n', '<leader>fb', telescope_builtin.buffers, { desc = "Find buffers" })
vim.keymap.set('n', '<leader>fh', telescope_builtin.help_tags, { desc = "Find help" })
vim.keymap.set('n', '<leader>fr', telescope_builtin.oldfiles, { desc = "Recent files" })
vim.keymap.set('n', '<leader>fk', telescope_builtin.keymaps, { desc = "Find keymaps" })
vim.keymap.set('n', '<leader>fc', telescope_builtin.colorscheme, { desc = "Find colorscheme" })

-- Quick shortcuts for common searches
vim.keymap.set('n', '<leader><space>', telescope_builtin.find_files, { desc = "Find files" })
vim.keymap.set('n', '<leader>/', telescope_builtin.live_grep, { desc = "Search text" })

-- Git operations with <leader>g prefix
vim.keymap.set('n', '<leader>gc', telescope_builtin.git_commits, { desc = "Git commits" })
vim.keymap.set('n', '<leader>gb', telescope_builtin.git_branches, { desc = "Git branches" })
vim.keymap.set('n', '<leader>gs', telescope_builtin.git_status, { desc = "Git status" })
