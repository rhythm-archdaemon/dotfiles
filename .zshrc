# ─── System Info ──────────────────────────────────────────────────────────────
macchina

# ─── Powerlevel10k Instant Prompt ─────────────────────────────────────────────
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ─── Oh My Zsh ────────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-history-substring-search
)

source $ZSH/oh-my-zsh.sh

# ─── Completion ───────────────────────────────────────────────────────────────
autoload -Uz compinit && compinit

zstyle ':completion:*' menu select                  # arrow-key navigable menu
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # case-insensitive matching
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # colored completions
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion::complete:*' use-cache on       # cache completions
zstyle ':completion::complete:*' cache-path "$HOME/.zsh/cache"

# ─── History ──────────────────────────────────────────────────────────────────
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"
setopt HIST_IGNORE_DUPS       # skip duplicate entries
setopt HIST_IGNORE_SPACE      # skip entries starting with a space
setopt SHARE_HISTORY          # share history across sessions

# ─── Aliases ──────────────────────────────────────────────────────────────────
# Add your aliases here, e.g.:
# alias ll='ls -lah'
# alias zshconfig='$EDITOR ~/.zshrc'

# ─── Powerlevel10k Config ─────────────────────────────────────────────────────
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
