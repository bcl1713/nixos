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
  local bufmap = function(keys, func)
    vim.keymap.set('n', keys, func, { buffer = bufnr })
  end

  -- LSP keymappings
  bufmap('<leader>r', vim.lsp.buf.rename)
  bufmap('<leader>a', vim.lsp.buf.code_action)

  bufmap('gd', vim.lsp.buf.definition)
  bufmap('gD', vim.lsp.buf.declaration)
  bufmap('gI', vim.lsp.buf.implementation)
  bufmap('<leader>D', vim.lsp.buf.type_definition)

  bufmap('gr', require('telescope.builtin').lsp_references)
  bufmap('<leader>s', require('telescope.builtin').lsp_document_symbols)
  bufmap('<leader>S', require('telescope.builtin').lsp_dynamic_workspace_symbols)

  bufmap('K', vim.lsp.buf.hover)

  -- Create Format command
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format({ bufnr = bufnr })
  end, {})

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

-- Setup capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Configure Lua LSP
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

-- Setup nil_ls for Nix files
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

-- Setup nixd for improved Nix LSP support
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
