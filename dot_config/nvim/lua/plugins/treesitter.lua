-- Treesitter configuration

return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "bash",
      "fish",
      "lua",
      "python",
      "javascript",
      "typescript",
      "tsx",
      "json",
      "yaml",
      "toml",
      "markdown",
      "markdown_inline",
      "vim",
      "vimdoc",
    },
    auto_install = true,
  },
}
