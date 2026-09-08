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
eval "$(zoxide init zsh --cmd cd)"
eval "$(starship init zsh)"
source <(fzf --zsh) 2>/dev/null
