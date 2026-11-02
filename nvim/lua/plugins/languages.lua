return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        codebook = {},
        marksman = {},
        jsonls = {},
        eslint = {},
        yamlls = {
          settings = {
            redhat = { telemetry = { enabled = false } },
          },
        },
      },
    },
  },
}
