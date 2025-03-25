-- user/app/neovim/nvim/plugin/git.lua

-- Gitsigns configuration
require('gitsigns').setup {
  signs                        = {
    add          = { text = '│' },
    change       = { text = '│' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  signcolumn                   = true,  -- Toggle with `:Gitsigns toggle_signs`
  numhl                        = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl                       = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff                    = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir                 = {
    follow_files = true
  },
  attach_to_untracked          = true,
  current_line_blame           = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts      = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
  },
  current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
  sign_priority                = 6,
  update_debounce              = 100,
  status_formatter             = nil,   -- Use default
  max_file_length              = 40000, -- Disable if file is longer than this (in lines)
  preview_config               = {
    -- Options passed to nvim_open_win
    border = 'rounded',
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },

  -- Key mappings
  on_attach                    = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, key, cmd, desc)
      vim.keymap.set(mode, key, cmd, { buffer = bufnr, desc = desc })
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, "Next git hunk")

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, "Previous git hunk")

    -- Actions with <leader>g prefix
    map('n', '<leader>gs', gs.stage_hunk, "Stage hunk")
    map('n', '<leader>gr', gs.reset_hunk, "Reset hunk")
    map('v', '<leader>gs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end, "Stage selected hunks")
    map('v', '<leader>gr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end, "Reset selected hunks")
    map('n', '<leader>gS', gs.stage_buffer, "Stage buffer")
    map('n', '<leader>gu', gs.undo_stage_hunk, "Undo stage hunk")
    map('n', '<leader>gR', gs.reset_buffer, "Reset buffer")
    map('n', '<leader>gp', gs.preview_hunk, "Preview hunk")
    map('n', '<leader>gb', function() gs.blame_line { full = true } end, "Blame line")
    map('n', '<leader>gt', gs.toggle_current_line_blame, "Toggle line blame")
    map('n', '<leader>gd', gs.diffthis, "Diff against index")
    map('n', '<leader>gD', function() gs.diffthis('~1') end, "Diff against previous commit")
    map('n', '<leader>g+', gs.toggle_deleted, "Toggle deleted")

    -- Text object
    map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', "Select hunk")
  end
}

-- Fugitive setup for :Git commands
vim.cmd [[
  command! -nargs=* G Git <args>
]]

-- Add completion for Git commands
vim.api.nvim_create_autocmd("FileType", {
  pattern = "fugitive",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})

-- Configure Diffview
require("diffview").setup({
  enhanced_diff_hl = true,
  view = {
    default = {
      layout = "diff2_horizontal",
      winbar_info = false,
    },
    merge_tool = {
      layout = "diff3_horizontal",
      disable_diagnostics = true,
      winbar_info = true,
    },
    file_history = {
      layout = "diff2_horizontal",
      winbar_info = false,
    },
  },
  file_panel = {
    listing_style = "tree",
    tree_options = {
      flatten_dirs = true,
      folder_statuses = "only_folded",
    },
    win_config = {
      width = 35,
    },
  },
  commit_log_panel = {
    win_config = {},
  },
  default_args = {
    DiffviewOpen = {},
    DiffviewFileHistory = {},
  },
  hooks = {},
  keymaps = {
    view = {
      ["q"] = function() require("diffview").close() end,
      ["<tab>"] = function() require("diffview.actions").select_next_entry() end,
      ["<s-tab>"] = function() require("diffview.actions").select_prev_entry() end,
      ["<leader>e"] = function() require("diffview.actions").focus_files() end,
      ["<leader>b"] = function() require("diffview.actions").toggle_files() end,
    },
    file_panel = {
      ["q"] = function() require("diffview").close() end,
      ["<tab>"] = function() require("diffview.actions").select_next_entry() end,
      ["<s-tab>"] = function() require("diffview.actions").select_prev_entry() end,
      ["<cr>"] = function() require("diffview.actions").goto_file() end,
      ["<c-e>"] = function() require("diffview.actions").goto_file_edit() end,
    },
    file_history_panel = {
      ["q"] = function() require("diffview").close() end,
      ["<tab>"] = function() require("diffview.actions").select_next_entry() end,
      ["<s-tab>"] = function() require("diffview.actions").select_prev_entry() end,
      ["<cr>"] = function() require("diffview.actions").goto_file() end,
      ["<c-e>"] = function() require("diffview.actions").goto_file_edit() end,
    },
  },
})
