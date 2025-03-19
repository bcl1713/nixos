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
  win = {
    border = "rounded",
    padding = { 2, 2, 2, 2 },
  },
}

wk.add({
  { "<leader>m", group = "Markdown" },
})
