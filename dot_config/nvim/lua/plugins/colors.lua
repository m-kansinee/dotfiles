-- Colorscheme configuration

return {
  -- Catppuccin Mocha colorscheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false, -- Load immediately (not lazy)
    priority = 1000, -- Load before other plugins
    opts = {
      flavour = "mocha", -- latte, frappe, macchiato, mocha
      background = {
        light = "latte",
        dark = "mocha",
      },
      transparent_background = false,
      show_end_of_buffer = true,
      integration_default = false,
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = false,
        mini = false,
        telescope = true,
        which_key = true,
      },
      highlight_overrides = {
        -- Add custom highlights here if needed
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd("colorscheme catppuccin-mocha")
    end,
  },
}
