local wk = require("which-key")

wk.setup {
  plugins = {
    marks = true,
    registers = true,
    spelling = {
      enabled = true,
      suggestions = 20,
    },
  },
  -- Use win instead of window (fixing the deprecation warning)
  icons = {
    breadcrumb = "»",
    separator = "➜",
    group = "+",
  },
  -- Proper scroll mappings without using deprecated option
  keys = {
    scroll_down = "<c-d>",
    scroll_up = "<c-u>",
  },
  layout = {
    height = { min = 4, max = 25 },
    width = { min = 20, max = 50 },
    spacing = 3,
    align = "center",
  },
}

wk.add({
  { "<leader>b", group = "buffer" },
  { "<leader>d", group = "diagnostics" },
  { "<leader>f", group = "find/file" },
  { "<leader>g", group = "git" },
  { "<leader>l", group = "lsp" },
  { "<leader>m", group = "markdown" },
  { "<leader>s", group = "search" },
  { "<leader>t", group = "table" },
  { "<leader>w", group = "window" },
})
