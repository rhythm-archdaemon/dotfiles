return {
  {
    'nvim-telescope/telescope.nvim', version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
      local builtin = require("telescope.builtin")

      -- Simple keymaps to get you started mapping Telescope finders
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope Find Files" })
      vim.keymap.set("n", "<leader>gg", builtin.live_grep, { desc = "Telescope Live Grep" })

      require("telescope").setup({
        -- Your custom telescope configurations go here
      })
    end,
  },

  {
    'nvim-telescope/telescope-ui-select.nvim',
    config = function()
      require("telescope").setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown {
              -- even more opts
            }
          }
        }
      })
      require("telescope").load_extension("ui-select")

    end,
  }
}
