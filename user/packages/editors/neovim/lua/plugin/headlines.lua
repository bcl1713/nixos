require("headlines").setup {
  markdown = {
    headline_highlights = {
      "Headline1",
      "Headline2",
      "Headline3",
      "Headline4",
      "Headline5",
      "Headline6",
    },
    codeblock_highlight = "CodeBlock",
    dash_highlight = "Dash",
    quote_highlight = "Quote",
    fat_headlines = true,
    fat_headline_upper_string = "▃",
    fat_headline_lower_string = "▀",
  },
}

-- Create highlight groups for headlines
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "Headline1", { fg = "#f38ba8", bold = true })
    vim.api.nvim_set_hl(0, "Headline2", { fg = "#fab387", bold = true })
    vim.api.nvim_set_hl(0, "Headline3", { fg = "#f9e2af", bold = true })
    vim.api.nvim_set_hl(0, "Headline4", { fg = "#a6e3a1", bold = true })
    vim.api.nvim_set_hl(0, "Headline5", { fg = "#89b4fa", bold = true })
    vim.api.nvim_set_hl(0, "Headline6", { fg = "#cba6f7", bold = true })
    vim.api.nvim_set_hl(0, "CodeBlock", { bg = "#242634" })
    vim.api.nvim_set_hl(0, "Quote", { fg = "#7f849c", italic = true })
    vim.api.nvim_set_hl(0, "Dash", { fg = "#f38ba8", bold = true })
  end,
})
