# ─── System Info ──────────────────────────────────────────────────────────────
macchina

# ─── Oh My Zsh ────────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-history-substring-search
)

source $ZSH/oh-my-zsh.sh

# ─── Completion ───────────────────────────────────────────────────────────────
autoload -Uz compinit && compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "$HOME/.zsh/cache"

# ─── History ──────────────────────────────────────────────────────────────────
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# ─── Aliases ──────────────────────────────────────────────────────────────────
# Add your aliases here, e.g.:
# alias ll='ls -lah'
# alias zshconfig='$EDITOR ~/.zshrc'

# ─── Starship Prompt ──────────────────────────────────────────────────────────
eval "$(starship init zsh)"
