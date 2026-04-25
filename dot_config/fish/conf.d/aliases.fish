# Aliases — grouped logically
# Note: git shortcuts use abbr (abbreviations) so history records full commands
#       and tab completion works on the expanded form.

# === Listing ===
if command -q eza
    alias ls   'eza --icons'
    alias ll   'eza -la --git --icons'
    alias tree 'eza --tree'
    alias lt   'eza -lTg --icons'
    alias lt1  'lt --level=1'
    alias lt2  'lt --level=2'
    alias lt3  'lt --level=3'
    alias lta  'lt -a'
    alias lta1 'lta --level=1'
    alias lta2 'lta --level=2'
    alias lta3 'lta --level=3'
else
    alias ls  "command ls -p -G"
    alias la  "ls -A"
    alias ll  "ls -l"
    alias lla "ll -A"
end

# === Git abbreviations ===
abbr -a ga  git add
abbr -a gb  git branch
abbr -a gc  git commit
abbr -a gco git checkout
abbr -a gd  git diff
abbr -a gds git diff --staged
abbr -a gl  git log --oneline --graph --decorate
abbr -a gp  git push
abbr -a gpl git pull
abbr -a gs  git status

# Use delta for git diffs if available
if command -q delta
    set -gx GIT_PAGER delta
end

# === Utilities ===
# Note: these shadow system commands in interactive sessions only (not in scripts)
if command -q bat
    alias cat bat
end
if command -q rg
    # rg flags differ from grep — use /usr/bin/grep in scripts
    alias grep rg
end
if command -q fd
    alias find fd
end

# === Dev tools ===
alias v    nvim
alias vim  nvim
alias c    claude
alias ccode 'code .'
alias claude-yolo "claude --dangerously-skip-permissions"
if command -q gemini
    alias g gemini
end

# === Tmux ===
alias ta 'tmux attach-session -t'
alias tl 'tmux list-sessions'
alias tn 'tmux new-session -s'

# === Docker ===
if command -q docker
    alias d     docker
    alias dps   'docker ps'
    alias dpsa  'docker ps -a'
    alias dim   'docker images'
    alias dex   'docker exec -it'
    alias dl    'docker logs -f'
    alias drm   'docker rm'
    alias drmi  'docker rmi'
    alias dprune 'docker system prune -f'
    alias dc    'docker compose'
    alias dcu   'docker compose up -d'
    alias dcd   'docker compose down'
    alias dcl   'docker compose logs -f'
    alias dcps  'docker compose ps'
end
