-- Telescope configuration

return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      layout_config = {
        horizontal = {
          preview_width = 0.55,
        },
      },
      file_ignore_patterns = {
        "node_modules",
        ".git",
        "venv",
        ".venv",
        "__pycache__",
      },
    },
  },
}
