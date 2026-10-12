return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        harper_ls = {},
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
