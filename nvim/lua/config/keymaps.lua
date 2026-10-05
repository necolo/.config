-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("x", "<leader>cy", function()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    vim.notify("Save this buffer with a filename first", vim.log.levels.WARN)
    return
  end

  local first, last = vim.fn.line("v"), vim.fn.line(".")
  first, last = math.min(first, last), math.max(first, last)
  local lines = vim.api.nvim_buf_get_lines(0, first - 1, last, false)
  local code = table.concat(lines, "\n")
  local fence = "```"
  for ticks in code:gmatch("`+") do
    if #ticks >= #fence then
      fence = string.rep("`", #ticks + 1)
    end
  end
  local text = string.format("%s:%d-%d\n%s%s\n%s\n%s", path, first, last, fence, vim.bo.filetype, code, fence)
  vim.fn.setreg("+", text)
  vim.cmd("normal! " .. vim.api.nvim_replace_termcodes("<Esc>", true, false, true))
  vim.notify("Copied " .. path .. ":" .. first .. "-" .. last)
end, { desc = "Copy lines with file context" })
