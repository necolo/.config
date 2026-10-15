return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        codebook = {},
        harper_ls = {
          filetypes = {
            "markdown",
            "text",
            "gitcommit",
          },
          settings = {
            ["harper-ls"] = {
              dialect = "British",
              diagnosticSeverity = "hint",
            },
          },
        },
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
