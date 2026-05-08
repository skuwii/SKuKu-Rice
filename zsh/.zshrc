# ╔═══════════════════════════════════════╗
# ║         STR TERMINAL v3.0             ║
# ║         .zshrc — skuwii               ║
# ╚═══════════════════════════════════════╝

# ── tmux auto-start ──
if command -v tmux &>/dev/null && [ -z "$TMUX" ]; then
    exec tmux
fi

# ── Oh My ZSH ──
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # Disabled — using custom prompt below
plugins=(git sudo zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# ── Fastfetch on launch ──
fastfetch

# ── Environment ──
export EDITOR="nvim"
export VISUAL="nvim"
export TERMINAL="kitty"
export BROWSER="brave"
export PATH="$HOME/.local/bin:$PATH"

# ── STR Prompt ──
# S❯ in azure, directory in bright, git branch in dim
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' %F{#4a4e56}  %b%f'
zstyle ':vcs_info:git:*' actionformats ' %F{#c0392b}  %b|%a%f'
setopt PROMPT_SUBST

PROMPT='%F{blue}%BS%b%f%F{blue}❯%f %F{white}%~%f${vcs_info_msg_0_} '
RPROMPT='%(?..%F{red}✗ %?%f)'

# ── Aliases ──
alias ls="eza --icons --group-directories-first"
alias ll="eza -la --icons --group-directories-first"
alias lt="eza --tree --icons --level=2"
alias cat="bat --theme=base16"
alias grep="grep --color=auto"
alias ..="cd .."
alias ...="cd ../.."
alias pt="/usr/lib/packettracer/packettracer.AppImage"

# Arch
alias pac="sudo pacman -S"
alias pacs="pacman -Ss"
alias pacu="sudo pacman -Syu"
alias pacr="sudo pacman -Rns"
alias yay="yay --cleanafter"

# Git
alias gs="git status"
alias ga="git add"
alias gc="git commit -m"
alias gp="git push"
alias gl="git log --oneline --graph --decorate -15"
alias gd="git diff"

# STR
alias rice="cd ~/.dotfiles"
alias eww-reload="eww kill && eww daemon && eww open left-panel && eww open right-panel && eww open bottom-bar"
alias waybar-reload="killall waybar; waybar &"

# ── History ──
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# ── Completion ──
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ── Syntax Highlighting Colors ──
ZSH_HIGHLIGHT_STYLES[command]='fg=#2980d4'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#2980d4'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#5ba3e0'
ZSH_HIGHLIGHT_STYLES[function]='fg=#5ba3e0'
ZSH_HIGHLIGHT_STYLES[path]='fg=#c8ccd4,underline'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#8a7e56'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#8a7e56'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#c0392b'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#5ba3e0'
ZSH_HIGHLIGHT_STYLES[default]='fg=#8a8f98'

# ── Autosuggestion ──
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#4a4e56'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# ── zoxide (smart cd) ──
eval "$(zoxide init zsh)"

# fzf
source <(fzf --zsh)

# zoxide (smart cd)
eval "$(zoxide init zsh)"
alias cd="z"

# eza (better ls)
alias ls="eza --icons --group-directories-first"
alias ll="eza -la --icons --group-directories-first"
alias lt="eza --tree --icons --level=2"

# bat (better cat)
alias cat="bat --style=plain --paging=never"


export PATH=$PATH:/home/yousef/.spicetify
alias ai="cd ~/ai && source ~/ai/env/bin/activate && jupyter lab --notebook-dir=/home/yousef/ai/notebooks"

# Import colorscheme from 'wal' asynchronously
# &   # Run the process in the background.
# ( ) # Hide shell job control messages.
(cat ~/.cache/wal/sequences &)

# bun completions
[ -s "/home/yousef/.bun/_bun" ] && source "/home/yousef/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# brain-sync aliases
alias brain-pull='~/.dotfiles/scripts/sync-brain.sh pull'
alias brain-push='~/.dotfiles/scripts/sync-brain.sh push'
