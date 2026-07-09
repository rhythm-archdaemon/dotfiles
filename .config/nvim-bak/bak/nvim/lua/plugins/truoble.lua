return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("trouble").setup()

        vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>")
        vim.keymap.set("n", "<leader>xf", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>")
    end,
}
