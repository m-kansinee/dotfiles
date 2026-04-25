# Tool initialization
# This file handles initialization for various development tools
# Loaded automatically by fish via conf.d mechanism

# === fnm (Fast Node Manager) ===
# fnm manages Node.js versions
if command -q fnm
    fnm env --shell fish | source
end

# === direnv (per-directory environment) ===
# direnv loads/unloads environment variables based on directory
if command -q direnv
    direnv hook fish | source
end

# === Rust/Cargo ===
if test -d "$HOME/.cargo/bin"
    fish_add_path --path --move "$HOME/.cargo/bin"
end

# === AWS CLI ===
# AWS_PROFILE / AWS_DEFAULT_REGION set per project via direnv .envrc

# === Google Cloud SDK ===
if test -d "$HOME/google-cloud-sdk/bin"
    fish_add_path "$HOME/google-cloud-sdk/bin"
end

# === zoxide (fast directory jumper, replaces z) ===
if command -q zoxide
    zoxide init fish | source
end
