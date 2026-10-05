-- Run: nvim --headless -u NONE -l ~/.config/nvim/tests/copy-context.lua
local mapping
local set_keymap, setreg, notify = vim.keymap.set, vim.fn.setreg, vim.notify
local copied, warning
vim.keymap.set = function(mode, lhs, callback)
  assert(mode == "x" and lhs == "<leader>cy")
  mapping = callback
end
vim.fn.setreg = function(register, text)
  assert(register == "+")
  copied = text
end
vim.notify = function(message, level)
  if level == vim.log.levels.WARN then
    warning = message
  end
end
dofile(vim.fn.expand("~/.config/nvim/lua/config/keymaps.lua"))

vim.api.nvim_buf_set_name(0, "/tmp/agent-context.lua")
local path = vim.api.nvim_buf_get_name(0)
vim.bo.filetype = "lua"
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "first", "local x = 1", "print(x)", "last" })
for _, selection in ipairs({ "2GVj", "3GVk", "2Gvj" }) do
  copied = nil
  vim.cmd("normal! " .. selection)
  mapping()
  assert(copied == path .. ":2-3\n```lua\nlocal x = 1\nprint(x)\n```", selection .. ": " .. tostring(copied))
  assert(vim.fn.mode() == "n")
end

vim.api.nvim_buf_set_lines(0, 1, 3, false, { "```", "print(x)" })
vim.cmd("normal! 2GVj")
mapping()
assert(copied == path .. ":2-3\n````lua\n```\nprint(x)\n````")

vim.cmd("enew!")
copied = nil
vim.cmd("normal! V")
mapping()
assert(copied == nil and warning ~= nil)
vim.cmd("normal! " .. vim.api.nvim_replace_termcodes("<Esc>", true, false, true))
vim.keymap.set, vim.fn.setreg, vim.notify = set_keymap, setreg, notify
print("copy-context: all checks passed (clipboard mocked)")
