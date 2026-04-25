# -----------------------------
# macOS fish config
# -----------------------------

# No greeting
set -g fish_greeting

# Set editor
set -gx EDITOR nvim
set -gx VISUAL nvim

# Set language
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8

# -----------------------------
# PATH
# -----------------------------
fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin
fish_add_path $HOME/bin
fish_add_path $HOME/.local/bin

# -----------------------------
# Homebrew
# -----------------------------
set -gx HOMEBREW_FORCE_BREWED_CURL 1

# -----------------------------
# Python (uv)
# uv installs to ~/.local/bin which is already in PATH above
# -----------------------------

# -----------------------------
# Java
# -----------------------------
if test -d /opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home
    set -gx JAVA_HOME /opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home
end

# -----------------------------
# SSH agent
# -----------------------------
if status is-interactive; and not set -q SSH_CONNECTION
    ssh-add -l >/dev/null 2>&1; or ssh-add --apple-load-keychain -q 2>/dev/null
end

# -----------------------------
# Starship prompt
# -----------------------------
if command -q starship
    starship init fish | source
end
