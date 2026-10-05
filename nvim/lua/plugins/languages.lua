return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        marksman = {},
        jsonls = {},
        yamlls = {
          settings = {
            redhat = { telemetry = { enabled = false } },
          },
        },
      },
    },
  },
}
