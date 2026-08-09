return {
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {
      window = {
        backdrop = 1, -- Keep full opacity
        width = 0.98, -- Stretch almost edge-to-edge
        height = 0.96,
        options = {
          signcolumn = "yes",
          number = true,
          relativenumber = true,
        },
      },
      plugins = {
        options = {
          enabled = true,
          ruler = false,
          showcmd = false,
        },
        twilight = { enabled = false },
        gitsigns = { enabled = true },
        tmux = { enabled = false },
      },
      on_open = function(win)
        -- Set a solid white border around the entire window
        vim.api.nvim_win_set_config(win, {
          border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
        })
        vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#ffffff", bg = "NONE" })
      end,
    },
  },
}
