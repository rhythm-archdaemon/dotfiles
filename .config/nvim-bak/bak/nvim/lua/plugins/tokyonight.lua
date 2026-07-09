return {
  "folke/tokyonight.nvim",
  lazy = false, -- ensures it loads immediately on startup
  priority = 1000, -- loads this before all other plugins
  config = function()
    vim.cmd.colorscheme("tokyonight-night")
  end,
}
