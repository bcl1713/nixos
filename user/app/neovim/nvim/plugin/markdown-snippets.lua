local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

-- Load friendly-snippets
require("luasnip.loaders.from_vscode").lazy_load()

-- Add custom markdown snippets
ls.add_snippets("markdown", {
  -- Create a link
  s("link", {
    t("["), i(1, "title"), t("]("), i(2, "url"), t(")"),
  }),

  -- Create a fenced code block
  s("code", {
    t("```"), i(1, "language"), t({ "", "" }),
    i(2, "code"), t({ "", "```" }),
  }),

  -- Create a table
  s("table", {
    t({ "| " }), i(1, "Header 1"), t({ " | " }), i(2, "Header 2"), t({ " |", "" }),
    t({ "| --- | --- |", "" }),
    t({ "| " }), i(3, "Row 1 Col 1"), t({ " | " }), i(4, "Row 1 Col 2"), t({ " |", "" }),
    t({ "| " }), i(5, "Row 2 Col 1"), t({ " | " }), i(6, "Row 2 Col 2"), t({ " |" }),
  }),

  -- Create a task list
  s("task", {
    t("- [ ] "), i(1, "Task description")
  }),

  -- Create frontmatter
  s("frontmatter", {
    t({ "---", "" }),
    t("title: "), i(1, "Title"), t({ "", "" }),
    t("date: "), f(function() return os.date("%Y-%m-%d") end), t({ "", "" }),
    t("tags: ["), i(2, "tag1, tag2"), t({ "]", "" }),
    t({ "---", "", "" }),
    i(0)
  }),
})

-- Add to luasnip configuration in cmp.lua or in a separate file loaded from there
