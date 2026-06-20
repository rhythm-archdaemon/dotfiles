return {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
        require("nvim-autopairs").setup({
            check_ts = true,  -- uses treesitter to be smarter about pairing
        })
    end,
}
