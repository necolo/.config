local exclude = {
  "**/.git",
  "**/node_modules",
  "**/dist",
  "**/.DS_Store",
  "**/.jj",
}

return {
  {
    "folke/snacks.nvim",
    opts = {
      lazygit = {
        config = {
          os = {
            edit = [[nvim --server "$NVIM" --remote-send "<C-\><C-n>q" && nvim --server "$NVIM" --remote {{filename}}]],
            editAtLine = [[nvim --server "$NVIM" --remote-send "<C-\><C-n>q" && nvim --server "$NVIM" --remote {{filename}} && nvim --server "$NVIM" --remote-send ":{{line}}<CR>"]],
          },
        },
      },
      picker = {
        sources = {
          explorer = { hidden = true, ignored = true, exclude = exclude },
          files = { hidden = true, ignored = true, exclude = exclude },
          grep = { hidden = true, ignored = true, exclude = exclude },
        },
      },
    },
  },
}
