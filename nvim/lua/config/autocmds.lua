-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- vtsls attaches this VS Code telemetry command to organizeImports actions.
-- Neovim has no client handler for it, so register a no-op.
vim.lsp.commands["_typescript.didOrganizeImports"] = function() end

local function code_action(kind)
  return function(bufnr)
    vim.lsp.buf.code_action({
      context = { only = { kind }, diagnostics = {} },
      apply = true,
      filter = function(_, client_id)
        local client = vim.lsp.get_client_by_id(client_id)
        return client ~= nil and client.name == "vtsls"
      end,
    })
  end
end

-- Runs only when the eslint server is attached, i.e. the project has an eslint config.
local function eslint_fix_all(bufnr)
  if #vim.lsp.get_clients({ bufnr = bufnr, name = "eslint" }) > 0 then
    vim.api.nvim_buf_call(bufnr, function()
      vim.cmd("LspEslintFixAll")
    end)
  end
end

local ts_on_save = {
  code_action("source.addMissingImports.ts"),
  code_action("source.removeUnusedImports.ts"),
  code_action("source.organizeImports"),
  eslint_fix_all,
}

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("ts_on_save", { clear = true }),
  pattern = { "*.ts", "*.tsx" },
  callback = function(args)
    for _, action in ipairs(ts_on_save) do
      action(args.buf)
    end
  end,
})
