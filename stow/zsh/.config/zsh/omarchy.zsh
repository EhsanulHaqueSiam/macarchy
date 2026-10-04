# Omarchy shell defaults, macOS edition (aliases from omarchy/default/bash/aliases).
export EDITOR=nvim
alias ls='eza -lh --group-directories-first --icons=auto'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias eff='$EDITOR "$(ff)"'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias c='opencode --auto'
alias cx='printf "\033[2J\033[3J\033[H" && claude --dangerously-skip-permissions'
alias cy='codex --approve-for-me'
alias d='docker'
alias t='tmux attach || tmux new -s Work'
alias mup='MISE_MINIMUM_RELEASE_AGE=0 mise up'
n() { if [ "$#" -eq 0 ]; then command nvim . ; else command nvim "$@"; fi; }
alias g='git'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'
alias lg='lazygit'

# Line editing as in Omarchy's bash (default/bash/inputrc). Emacs keys first:
# zsh silently picks vi mode when $EDITOR contains "vi", and EDITOR is nvim.
bindkey -e
# Up/Down search history for what is typed so far.
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search; zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search; bindkey '^[OA' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search; bindkey '^[OB' down-line-or-beginning-search
# Word jumps: Ctrl+arrows as on Linux; ⌘+arrows, which Ghostty sends as Alt+arrows
# (Hyprland ALT = ⌘). Ctrl+Backspace/Delete kill a word. Home/End.
bindkey '^[[1;5D' backward-word; bindkey '^[[1;5C' forward-word
bindkey '^[[1;3D' backward-word; bindkey '^[[1;3C' forward-word
bindkey '^H' backward-kill-word; bindkey '^[[3;5~' kill-word; bindkey '^[[3~' delete-char
bindkey '^[[H' beginning-of-line; bindkey '^[OH' beginning-of-line
bindkey '^[[F' end-of-line; bindkey '^[OF' end-of-line
# Completion: case-insensitive, Tab/Shift+Tab cycle through a menu.
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select
bindkey '^[[Z' reverse-menu-complete

eval "$(zoxide init zsh --cmd cd)"
eval "$(starship init zsh)"
source <(fzf --zsh) 2>/dev/null
