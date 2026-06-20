return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons", 
  },
  lazy = false, -- neo-tree will lazily load itself
  config = function()
    vim.keymap.set('n', '<C-p>', ':Neotree filesystem reveal left<CR>', {})
  end
}
