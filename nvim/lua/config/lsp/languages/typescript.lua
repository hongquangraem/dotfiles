local lspconfig = require("lspconfig")
local capabilities = require("config.lsp.utils/capabilities")
local on_attach = require("config.lsp.utils/on_attach")

local baseDefinitionHandler = vim.lsp.handlers["textDocument/definition"]
local filter = require("config.lsp.utils.filter").filter
local filterReactDTS = require("config.lsp.utils.filterReactDTS").filterReactDTS

local handlers = {
  ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    silent = true,
    border = NeoVim.ui.float.border,
  }),
  ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = NeoVim.ui.float.border }),
  ["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics,
    { virtual_text = NeoVim.lsp.virtual_text }
  ),
  ["textDocument/definition"] = function(err, result, method, ...)
    P(result)
    if vim.tbl_islist(result) and #result > 1 then
      local filtered_result = filter(result, filterReactDTS)
      return baseDefinitionHandler(err, filtered_result, method, ...)
    end

    baseDefinitionHandler(err, result, method, ...)
  end,
}

local settings = {
  separate_diagnostic_server = true,
  tsserver_file_preferences = {
    includeInlayParameterNameHints = "all",
    includeCompletionsForModuleExports = true,
    quotePreference = "auto",
  },
}

local custom_on_attach = function(client, bufnr)
  client.server_capabilities.document_formatting = false
  on_attach(client, bufnr)

  local ts_utils = require("nvim-lsp-ts-utils")

  ts_utils.setup({
    update_imports_on_move = true,
  })
  ts_utils.setup_client(client)

  local opts = { silent = true }
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>fm", "<cmd>lua vim.lsp.buf.formatting()<CR>", {})
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>oi", ":TSLspOrganize<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>rn", ":TSLspRenameFile<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ia", ":TSLspImportAll<CR>", opts)
end

lspconfig.tsserver.setup({
  capabilities = capabilities,
  handlers = handlers,
  on_attach = custom_on_attach,
  settings = settings,
})
