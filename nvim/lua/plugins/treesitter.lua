---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    treesitter = {
      highlight = true,
      indent = true,
      auto_install = true,
      ensure_installed = {
        "lua", "vim", "vimdoc",
        "python",
        "c", "cpp",
        "javascript", "typescript", "tsx",
        "html", "css",
        "json", "yaml", "toml",
        "markdown", "markdown_inline",
        "bash",
      },
    },
  },
}
