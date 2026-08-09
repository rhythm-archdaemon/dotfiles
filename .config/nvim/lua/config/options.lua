-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- Single continuous line character for splits
vim.opt.fillchars = {
  horiz = "─",
  horizup = "┴",
  horizdown = "┬",
  vert = "│",
  vertleft = "┤",
  vertright = "├",
  verthoriz = "┼",
}

-- Force split lines and window borders to rendered white
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    local white = "#ffffff"

    -- Main window split separators
    vim.api.nvim_set_hl(0, "WinSeparator", { fg = white, bold = true })
    vim.api.nvim_set_hl(0, "VertSplit", { fg = white })

    -- Floating window borders (LSP hover, popups)
    vim.api.nvim_set_hl(0, "FloatBorder", { fg = white })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
  end,
})
