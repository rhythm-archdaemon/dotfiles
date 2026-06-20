# nvim

A personal, from-scratch Neovim configuration built on [lazy.nvim](https://github.com/folke/lazy.nvim), with each plugin isolated into its own file for clarity and easy maintenance. No distribution, no inherited defaults — every setting was added deliberately while building out a daily-driver IDE setup for Python, TypeScript/JavaScript, and Lua.

## Structure

```
.
├── init.lua
└── lua/
    ├── vim-options.lua
    └── plugins/
        ├── catppuccin.lua
        ├── completion.lua
        ├── lsp-config.lua
        ├── lualine.lua
        ├── neo-tree.lua
        ├── telescope.lua
        └── treesitter.lua
```

`init.lua` bootstraps `lazy.nvim` (cloning it on first run if missing), loads core options, and points lazy at the `plugins` directory where it auto-discovers every file.

## Core Editor Settings (`vim-options.lua`)

- System clipboard integration (`unnamedplus`) — yanks and pastes go through the Wayland clipboard, working seamlessly across terminal splits, tmux panes, and other applications.
- `wrap = false` with tuned `sidescroll`/`sidescrolloff` — long lines extend horizontally rather than wrapping, better suited for code with long function signatures or URLs.
- 2-space indentation (`expandtab`, `tabstop`, `softtabstop`, `shiftwidth` all set to 2).
- Leader key set to `<Space>`.
- Visual mode indent/outdent (`>` / `<`) re-selects the visual block afterward, so repeated indenting doesn't require re-selecting.

## Plugins

**Colorscheme** — `catppuccin.lua`
Sets the overall editor theme.

**LSP** — `lsp-config.lua`
Native Neovim 0.12 LSP configuration via `vim.lsp.config` / `vim.lsp.enable`, paired with `mason.nvim` and `mason-lspconfig.nvim` for automatic language server installation. Configured servers:
- `pyright` (Python)
- `ts_ls` (TypeScript/JavaScript)
- `lua_ls` (Lua, with `vim` recognized as a global)

LSP keybinds are registered on `LspAttach` under the leader key — go to definition, hover, references, rename, code actions, and diagnostic navigation, plus an enlarged rounded-border hover window for better readability.

**Completion** — `completion.lua`
`blink.cmp` for fast, LSP-aware autocompletion with snippet, path, and buffer sources.

**Treesitter** — `treesitter.lua`
Structure-aware syntax highlighting and indentation, with parsers installed on demand (`auto_install`) as new filetypes are opened, kept up to date via `:TSUpdate`.

**Fuzzy Finding** — `telescope.lua`
File, grep, and symbol navigation powered by `telescope.nvim` with the `fzf-native` extension for faster sorting.

**File Explorer** — `neo-tree.lua`
Sidebar file tree navigation with `nvim-web-devicons` for filetype icons.

**Statusline** — `lualine.lua`
Custom statusline themed to match Catppuccin.

## Workflow Notes

- Designed to be used alongside `tmux` for persistent terminal sessions next to the editor — the `DirChanged` autocommand in `init.lua` keeps Neovim's working directory in sync with the shell, so opening a terminal split lands in the same directory you're editing in.
- Built and used daily on Arch Linux with the **niri** scrollable-tiling Wayland compositor.

---

*Screenshots coming soon.*
