---@type LazySpec
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        -- LSPs
        "lua-language-server",
        "pyright",
        "clangd",
        "typescript-language-server",
        "html-lsp",
        "css-lsp",

        -- Formatters
        "stylua",
        "black",
        "clang-format",
        "prettier",

        -- Treesitter CLI
        "tree-sitter-cli",
      },
    },
  },
}
