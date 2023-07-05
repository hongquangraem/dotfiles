local null_ls = require("null-ls")

local formatting = null_ls.builtins.formatting   -- to setup formatters
local diagnostics = null_ls.builtins.diagnostics -- to setup linters

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

null_ls.setup({
   sources = {
      formatting.prettier,
      formatting.stylua,
      diagnostics.eslint_d.with({
         condition = function(utils)
            return utils.root_has_file(".eslintrc.js")
         end,
      }),
      -- null_ls.builtins.diagnostics.mypy,
      null_ls.builtins.diagnostics.ruff,
      null_ls.builtins.formatting.black,
   },
   -- configure format on save
   on_attach = function(current_client, bufnr)
      if current_client.supports_method("textDocument/formatting") then
         vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
         vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
               vim.lsp.buf.format({
                  -- filter = function(client)
                  -- 	--  only use null-ls for formatting instead of lsp server
                  -- 	return client.name == "null-ls"
                  -- end,
                  bufnr = bufnr,
               })
            end,
         })
      end
   end,
})
