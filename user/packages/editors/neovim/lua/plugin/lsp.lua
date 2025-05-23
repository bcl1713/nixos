-- Setup leader keys here because I need them to be the first thing that happens.

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Setup neodev for Neovim Lua development
-- This needs to be set up BEFORE lspconfig
require('neodev').setup({
  -- Enable neodev globally
  library = {
    enabled = true,
    runtime = true,
    plugins = true,
    types = true,
  },
  lspconfig = true,
})

local on_attach = function(client, bufnr)
  local bufmap = function(keys, func, desc)
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  bufmap('<leader>lr', vim.lsp.buf.rename, "Rename symbol")
  bufmap('<leader>la', vim.lsp.buf.code_action, "Code action")
  bufmap('<leader>ls', require('telescope.builtin').lsp_document_symbols, "Document symbols")
  bufmap('<leader>lS', require('telescope.builtin').lsp_dynamic_workspace_symbols, "Workspace symbols")
  bufmap('<leader>lt', vim.lsp.buf.type_definition, "Type definition")

  -- Keep standard Vim-like navigation commands
  bufmap('gd', vim.lsp.buf.definition, "Go to definition")
  bufmap('gD', vim.lsp.buf.declaration, "Go to declaration")
  bufmap('gI', vim.lsp.buf.implementation, "Go to implementation")
  bufmap('gr', require('telescope.builtin').lsp_references, "Find references")
  bufmap('K', vim.lsp.buf.hover, "Show hover documentation")

  -- Diagnostics mappings
  bufmap('<leader>dl', vim.diagnostic.setloclist, "Diagnostic list")
  bufmap('<leader>df', vim.diagnostic.open_float, "Line diagnostics")
  bufmap('[d', vim.diagnostic.goto_prev, "Previous diagnostic")
  bufmap(']d', vim.diagnostic.goto_next, "Next diagnostic")

  -- Create Format command
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format({ bufnr = bufnr })
  end, { desc = "Format current buffer" })

  -- Add format keymap
  bufmap('<leader>lf', function() vim.cmd("Format") end, "Format document")

  -- Setup format on save with a simpler approach
  if client.server_capabilities.documentFormattingProvider then
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 2000 })
      end
    })
  end
end

-- When you use the marksman LSP setup, modify it to use standardized markdown keymaps:
-- Setup capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Marksman
require('lspconfig').marksman.setup {
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)

    local bufmap = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end

    -- Toggle checkboxes with consistent 'm' prefix for markdown
    bufmap('<leader>mx', function()
      local line = vim.api.nvim_get_current_line()
      if line:match('%[%s%]') then
        line = line:gsub('%[%s%]', '[x]')
      elseif line:match('%[x%]') then
        line = line:gsub('%[x%]', '[ ]')
      end
      vim.api.nvim_set_current_line(line)
    end, "Toggle checkbox")
  end,
}

-- Lua LSP
require('lspconfig').lua_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = function()
    return vim.loop.cwd()
  end,
  cmd = { "lua-language-server" },
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  }
}

-- nil_ls
require('lspconfig').nil_ls.setup {
  autostart = true,
  capabilities = capabilities,
  on_attach = on_attach,
  cmd = { "nil" },
  settings = {
    ['nil'] = {
      formatting = {
        command = { "nixfmt" },
      },
    },
  },
}

-- nixd
require('lspconfig').nixd.setup {
  autostart = true,
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    ['nixd'] = {
      formatting = {
        command = "nixfmt",
      },
    },
  },
}

-- YAML Language Server
require('lspconfig').yamlls.setup {
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    yaml = {
      customTags = {
        "!include",
        "!include_dir_list",
        "!include_dir_named",
        "!include_dir_merge_list",
        "!include_dir_merge_named",
        "!secret",
        "!env_var",
        "!input",
        "!lambda",
        "!extend",
      },
      schemas = {
        -- Add more YAML schemas as needed
        ["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/*.{yml,yaml}",
        ["https://json.schemastore.org/kustomization.json"] = "kustomization.{yml,yaml}",
        ["https://json.schemastore.org/drone.json"] = ".drone.{yml,yaml}",
        ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "**/docker-compose*.{yml,yaml}",
      },
      -- Validate on save
      validate = true,
      -- Complete with all keywords
      completion = true,
      -- Enable hover with documentation
      hover = true,
      -- Format on save (handled by our format-on-save setup)
      format = {
        enable = true,
      },
    },
  },
}
