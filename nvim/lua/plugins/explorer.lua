local exclude = {
  "**/.git",
  "**/node_modules",
  "**/dist",
  "**/.DS_Store",
}

return {
  {
    "folke/snacks.nvim",
    opts = {
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
