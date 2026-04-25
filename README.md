# dotfiles

Personal development environment for macOS, managed with [chezmoi](https://chezmoi.io).

**Stack:** macOS · fish shell · WezTerm · Neovim (LazyVim) · tmux · Starship prompt · direnv · fnm · uv

---

## Table of Contents

1. [Installation](#installation)
2. [chezmoi — Dotfile Manager](#chezmoi--dotfile-manager)
3. [fish — Shell](#fish--shell)
4. [WezTerm — Terminal Emulator](#wezterm--terminal-emulator)
5. [Neovim — Editor](#neovim--editor)
6. [tmux — Terminal Multiplexer](#tmux--terminal-multiplexer)
7. [Starship — Prompt](#starship--prompt)
8. [direnv — Per-directory Environment](#direnv--per-directory-environment)
9. [git — Templates](#git--templates)
10. [Tips for Customization](#tips-for-customization)
11. [Recommended Improvements](#recommended-improvements)

---

## Installation

### Prerequisites

Install the following via [Homebrew](https://brew.sh) before applying dotfiles:

```sh
brew install chezmoi fish neovim tmux starship direnv fnm fzf eza bat ripgrep fd delta zoxide lazygit btop
```

Install WezTerm from the [official releases page](https://wezfurlong.org/wezterm/installation.html) (Homebrew cask also works: `brew install --cask wezterm`).

### Apply dotfiles

```sh
# Clone and apply in one step
chezmoi init --apply https://github.com/<your-username>/dotfiles

# Or if already cloned to ~/dotfiles
chezmoi apply
```

### Post-install

```sh
# Set fish as your default shell
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish

# Install fish plugins
fish -c "fisher update"

# Install Neovim plugins (headless)
nvim --headless "+Lazy! sync" +qa

# Install tmux plugins (inside a tmux session)
# Press: prefix + I
```

---

## chezmoi — Dotfile Manager

**What it does:** Tracks dotfiles from a source directory (`~/dotfiles`) and applies them to their destinations (e.g., `~/.config`). Handles templating, encrypted secrets, and executable bits.

### Configuration

`~/.config/chezmoi/chezmoi.toml`

| Setting | Value | Description |
|---|---|---|
| `sourceDir` | `~/dotfiles` | Where chezmoi reads source files from |

### Naming Conventions in `~/dotfiles/`

| Prefix | Effect |
|---|---|
| `dot_` | Becomes `.` in destination (e.g., `dot_config/` → `~/.config/`) |
| `private_` | File is encrypted at rest; chezmoi decrypts on apply |
| `executable_` | `chmod +x` is applied on destination file |

### Usage Examples

```fish
chezmoi apply                            # Apply all managed dotfiles
chezmoi diff                             # Preview what would change before applying
chezmoi verify                           # Check for drift between source and destination
chezmoi re-add                           # Sync changes made in ~/.config back to ~/dotfiles
chezmoi cd                               # cd into ~/dotfiles (the source dir)
chezmoi edit ~/.config/fish/config.fish  # Edit source file for a managed file
chezmoi add ~/.config/fish/config.fish   # Start tracking a new file
```

### Workflow

```fish
# 1. Edit source
chezmoi edit ~/.config/fish/conf.d/aliases.fish

# 2. Preview
chezmoi diff

# 3. Apply
chezmoi apply

# 4. Commit
cd ~/dotfiles && git add -A && git commit -m "describe change"
```

### Notes

- Changes made directly in `~/.config/` are **ephemeral** — they will be overwritten next time `chezmoi apply` runs.
- Always edit via `chezmoi edit <dest-path>` or directly in `~/dotfiles/dot_config/`.

---

## fish — Shell

**What it does:** A user-friendly shell with syntax highlighting, autosuggestions, and a sane scripting syntax. Replaces bash/zsh.

### Overview

Config loads in this order on every shell start:

1. `config.fish` — environment variables, PATH, SSH agent, Starship init
2. `conf.d/*.fish` — auto-sourced alphabetically: `aliases.fish`, `tools.fish`, `fzf.fish`

### Configuration Breakdown

#### `config.fish` — Core Environment

| Setting | Value | Description |
|---|---|---|
| `fish_greeting` | _(empty)_ | Disables the default "Welcome to fish" banner |
| `EDITOR` / `VISUAL` | `nvim` | Default editor for git commits, `crontab -e`, etc. |
| `LANG` / `LC_ALL` | `en_US.UTF-8` | Forces UTF-8 locale; prevents encoding issues in tools |
| `HOMEBREW_FORCE_BREWED_CURL` | `1` | Makes Homebrew use its own curl instead of macOS's older one |
| `JAVA_HOME` | Homebrew OpenJDK path | Set only if the Homebrew OpenJDK is installed |

**PATH additions** (in order of priority):

| Path | Purpose |
|---|---|
| `/opt/homebrew/bin` `/opt/homebrew/sbin` | Homebrew binaries (Apple Silicon) |
| `~/bin` | Personal scripts |
| `~/.local/bin` | Tools installed by uv, pipx, etc. |

**SSH agent:** On interactive non-SSH sessions, loads macOS Keychain keys automatically via `ssh-add --apple-load-keychain`. Keys stored in Keychain don't require passphrase re-entry.

**Local overrides:** `conf.d/config-local.fish` — use it for machine-specific secrets (API keys, AWS profiles).

```fish
# config-local.fish.example shows these placeholders:
# set -gx ANTHROPIC_API_KEY "sk-ant-..."
# set -gx AWS_PROFILE "default"
# set -gx WORKSPACE "$HOME/projects"
```

#### `conf.d/aliases.fish` — Aliases and Abbreviations

**Note:** Git shortcuts use `abbr` (abbreviations) rather than `alias`. Abbreviations expand in-place before execution, so your shell history records the full command (`git status`, not `gs`) and tab completion works on the expanded form.

**Listing:**

| Alias | Expands to | Condition |
|---|---|---|
| `ls` | `eza` | if eza installed |
| `ll` | `eza -la --git --icons` | if eza installed; shows hidden files, git status, icons |
| `lt` | `eza -lTg --icons` | if eza installed; shows all files Recurse into directories as a tree |
| `tree` | `eza --tree` | if eza installed |
| `ls` | `command ls -p -G` | fallback (no eza) |

**Git abbreviations:**

| Abbr | Expands to | Description |
|---|---|---|
| `ga` | `git add` | Stage files |
| `gb` | `git branch` | List / manage branches |
| `gc` | `git commit` | Commit staged changes |
| `gco` | `git checkout` | Switch branch or restore file |
| `gd` | `git diff` | Diff unstaged changes |
| `gds` | `git diff --staged` | Diff staged changes |
| `gl` | `git log --oneline --graph --decorate` | Compact decorated log |
| `gp` | `git push` | Push to remote |
| `gpl` | `git pull` | Pull from remote |
| `gs` | `git status` | Working tree status |

If [`delta`](https://github.com/dandavison/delta) is installed, it replaces the default git pager for all diff output (`GIT_PAGER=delta`).

**Utilities (conditional on install):**

| Alias | Replaces | Why |
|---|---|---|
| `cat` | `bat` | `bat` adds syntax highlighting and line numbers |
| `grep` | `rg` (ripgrep) | Faster, respects `.gitignore` by default |
| `find` | `fd` | Simpler syntax, respects `.gitignore` |

**Dev tools:**

| Alias | Expands to | Description |
|---|---|---|
| `v` / `vim` | `nvim` | Always use Neovim |
| `c` | `claude` | Claude Code CLI shorthand |
| `ccode` | `code .` | Open current dir in VS Code |
| `claude-yolo` | `claude --dangerously-skip-permissions` | Run Claude without permission prompts |
| `g` | `gemini` | Gemini CLI shorthand (if installed) |

**Tmux:**

| Alias | Expands to | Description |
|---|---|---|
| `ta <name>` | `tmux attach-session -t` | Attach to named session |
| `tl` | `tmux list-sessions` | List active sessions |
| `tn <name>` | `tmux new-session -s` | Create named session |

**Docker (only if docker installed):**

| Alias | Expands to |
|---|---|
| `d` | `docker` |
| `dps` | `docker ps` |
| `dpsa` | `docker ps -a` |
| `dim` | `docker images` |
| `dex` | `docker exec -it` |
| `dl` | `docker logs -f` |
| `drm` | `docker rm` |
| `drmi` | `docker rmi` |
| `dprune` | `docker system prune -f` |
| `dc` | `docker compose` |
| `dcu` | `docker compose up -d` |
| `dcd` | `docker compose down` |
| `dcl` | `docker compose logs -f` |
| `dcps` | `docker compose ps` |

#### `conf.d/tools.fish` — Tool Initialization

Initializes development tools that hook into the shell. Each block is gated on the tool being installed, so missing tools don't cause errors.

| Tool | Initialization | Purpose |
|---|---|---|
| `fnm` | `fnm env --shell fish \| source` | Activates the fast Node version manager |
| `direnv` | `direnv hook fish \| source` | Enables per-directory env loading via `.envrc` |
| Cargo | Adds `~/.cargo/bin` to PATH | Makes Rust-installed binaries available |
| Google Cloud SDK | Adds `~/google-cloud-sdk/bin` to PATH | Makes `gcloud`, `gsutil` available |
| `zoxide` | `zoxide init fish \| source` | Replaces `cd` with a frecency-based directory jumper |

#### `conf.d/fzf.fish` — Fuzzy Finder Bindings

Installs default `fzf.fish` keybindings. Only runs in interactive mode (no overhead on scripts or CI).

### Plugins (`fish_plugins`)

Managed by [fisher](https://github.com/jorgebucaran/fisher). Declared in `~/.config/fish/fish_plugins`:

| Plugin | What it does |
|---|---|
| `jorgebucaran/fisher` | Plugin manager itself |
| `patrickf1/colored_man_pages.fish` | Installs `man` and `cless` functions — `man` automatically pipes output through `cless` for colorized bold/underline rendering |
| `patrickf1/fzf.fish` | Integrates fzf into fish (file search, history, git status) |

#### fzf.fish Keybindings

| Key | Action |
|---|---|
| `Ctrl-F` | Search files in current directory |
| `Ctrl-R` | Search command history |
| `Ctrl-Alt-S` | Search git status (staged/unstaged files) |
| `Ctrl-Alt-L` | Search git log |
| `Ctrl-Alt-F` | Search directory recursively |
| `Ctrl-V` | Search shell variables |
| `Ctrl-P` | Search running processes |

### Custom Functions

#### `pyinit <version> [--git]`

Scaffolds a uv + direnv Python project in the current directory.

```fish
pyinit 3.12         # Creates .python-version, .envrc (layout uv), runs direnv allow
pyinit 3.11 --git   # Same + runs gitinit python
```

#### `nodeinit <version> [--git]`

Scaffolds an fnm + direnv Node.js project.

```fish
nodeinit 20         # Creates .node-version, .envrc (use node), runs direnv allow
nodeinit 18 --git   # Same + runs gitinit node
```

#### `gitinit <type> [--github]`

Initializes a git repo with a merged `.gitignore` (general + type-specific template).

```fish
gitinit python            # Creates .gitignore (general + python), README.md, initial commit
gitinit node --github     # Same for node, then creates a private GitHub repo via gh CLI
gitinit general           # General .gitignore only
```

Available types: `python`, `node`, `general`.

#### `cless <command>`

Installed by `colored_man_pages.fish`. Sets `LESS_TERMCAP_*` variables then runs the given command, making `less` output color-aware. Called automatically by the `man` wrapper — rarely needed directly.

```fish
cless man git    # man page with colored bold/underline/standout
```

### Usage Examples

```fish
# Jump to a previously visited directory
z dotfiles

# Fuzzy-find a file and open in nvim
nvim (fzf)

# Scaffold a new Python project
mkdir my-api && cd my-api && pyinit 3.12 --git

# Scaffold a Node project and push to GitHub
mkdir my-app && cd my-app && nodeinit 20 --github
```

---

## WezTerm — Terminal Emulator

**What it does:** A GPU-accelerated terminal emulator configured entirely in Lua. Replaces iTerm2 with native pane/tab management that mirrors a tmux-like workflow.

Config is split across four files:
- `wezterm.lua` — main config (assembles the others)
- `keybindings.lua` — all key and mouse bindings
- `statusbar.lua` — tab titles and right-status rendering
- `palette.lua` — color constants

### Configuration Breakdown

#### `wezterm.lua` — Core Settings

| Setting | Value | Description |
|---|---|---|
| `front_end` | `WebGpu` | GPU-accelerated renderer; `is_tart_vm = true` enables this unconditionally |
| `max_fps` | `60` | Cap render rate to prevent CPU/GPU thrashing |
| `animation_fps` | `30` | Animation frame rate (cursor blink, etc.) |
| `font` | `Hack Nerd Font Mono` | Monospace font with Nerd Font icons for statusbar glyphs |
| `font_size` | `13.0` | Base font size in points |
| `color_scheme` | `Catppuccin Mocha` | Dark theme; matches Neovim and tmux color scheme |
| `term` | `xterm-256color` | Terminal type advertised to programs; needed for 256-color and truecolor support |
| `window_decorations` | `RESIZE` | No macOS titlebar, only the resize handle; saves vertical space |
| `window_close_confirmation` | `NeverPrompt` | Closes window immediately without a dialog |
| `scrollback_lines` | `10000` | Lines of scrollback buffer kept in memory |
| `default_cursor_style` | `BlinkingBar` | Thin blinking bar cursor (vs block) |
| `window_background_opacity` | `1.0` | Fully opaque by default; toggle with `Cmd-U` |
| `window_padding` | `left=4, right=4, top=4, bottom=4` | Minimal padding to avoid clipping |
| `audible_bell` | `Disabled` | Suppresses the terminal bell sound |
| `initial_rows` / `initial_cols` | `40` / `120` | Default window size on launch |
| `use_fancy_tab_bar` | `false` | Uses the retro/custom tab bar instead of macOS-native style |
| `tab_bar_at_bottom` | `true` | Tab bar renders at the bottom (like tmux statusline) |
| `hide_tab_bar_if_only_one_tab` | `false` | Always shows the tab bar for consistency |
| `show_new_tab_button_in_tab_bar` | `false` | Removes the `+` button; use `Leader + c` instead |

#### `palette.lua` — Color Palette

The palette is referenced by both `statusbar.lua` and `wezterm.lua` to keep colors consistent.

| Variable | Hex | Used for |
|---|---|---|
| `bar_bg` | `#404063` | Tab bar background |
| `bar_fg` | `#839496` | Inactive tab text |
| `index_bg` | `#ffffff` | Active tab: index number box background |
| `index_fg` | `#b58900` | Active tab: index number color (gold) |
| `title_bg` | `#b58900` | Active tab: title background (gold) |
| `title_fg` | `#eee8d5` | Active tab: title text |
| `user_bg` | `#a8bcbc` | Right status: hostname pill background |
| `user_fg` | `#15161E` | Right status: text on light pill |
| `mid1_bg` | `#4a5a65` | Right status: fade step 1 |
| `mid2_bg` | `#6e8a94` | Right status: fade step 2 |

#### `statusbar.lua` — Tab Titles and Right Status

**Tab rendering:**
- **Active tab:** Powerline arrow → white index box → gold title box → arrow back to bar
- **Inactive tab:** Plain `index  title` with a thin `▷` separator between adjacent inactive tabs
- Titles are truncated to fit `max_width` with priority given to the title text

**Right status (normal mode):** Three Powerline `◀` arrows fading into the hostname pill (bold).

**Right status (fullscreen mode):** Adds battery percentage with icon (5 levels: empty → full) and current time (`HH:MM`).

### Keybindings

**Leader key:** `Ctrl-T` (1000 ms timeout)

All pane and tab operations require pressing `Ctrl-T` first, then the action key.

#### Pane Management

| Key | Action | Description |
|---|---|---|
| `Leader + %` | Split left/right | New pane opens to the right |
| `Leader + "` | Split top/bottom | New pane opens below |
| `Leader + w` | Close current pane | Prompts for confirmation |
| `Leader + h` or `←` | Focus left pane | |
| `Leader + j` or `↓` | Focus down pane | |
| `Leader + k` or `↑` | Focus up pane | |
| `Leader + l` or `→` | Focus right pane | |
| `Leader + Shift-H` | Resize pane left | Adjusts by 3 cells |
| `Leader + Shift-J` | Resize pane down | Adjusts by 3 cells |
| `Leader + Shift-K` | Resize pane up | Adjusts by 3 cells |
| `Leader + Shift-L` | Resize pane right | Adjusts by 3 cells |

#### Tab Management

| Key | Action | Description |
|---|---|---|
| `Leader + c` | New tab | Opens in same domain as current pane |
| `Leader + n` | Next tab | Wraps around |
| `Leader + p` | Previous tab | Wraps around |
| `Leader + 1–9` | Jump to tab N | Direct tab access by index |

#### Scrolling

| Key | Action |
|---|---|
| `Leader + u` | Scroll up half page |
| `Leader + d` | Scroll down half page |
| `Leader + PageUp` | Scroll to top |
| `Leader + PageDown` | Scroll to bottom |
| `Leader + Ctrl-L` | Clear scrollback and viewport |
| `Cmd-K` | Clear scrollback and viewport |

#### Window

| Key | Action | Description |
|---|---|---|
| `Cmd-Enter` | Toggle fullscreen | |
| `Cmd-M` | Minimize / exit fullscreen | If fullscreen, exits fullscreen; otherwise minimizes |
| `Cmd-U` | Toggle transparency | Toggles `window_background_opacity` between `1.0` and `0.85` |

#### Mouse

| Action | Result |
|---|---|
| `Ctrl + Right-click` | Copy selection to clipboard |

### Notes

- `selection_word_boundary` is set to `" \t\n{}[]()\"'\`,;:"` — double-clicking selects tokens without including delimiters.
- The config assumes Hack Nerd Font Mono is installed. Without it, Powerline arrows and battery/clock icons in the statusbar will render as boxes.

---

## Neovim — Editor

**What it does:** Vim-based editor extended with [LazyVim](https://lazyvim.org), a full IDE-like preset. LazyVim handles plugin management, LSP setup, and sensible defaults; this config layers on top.

Config lives in `~/.config/nvim/lua/`:
- `config/options.lua` — editor behavior
- `config/keymaps.lua` — custom key bindings
- `config/autocmds.lua` — autocommands
- `plugins/` — plugin-specific overrides

### Configuration Breakdown

#### `config/options.lua` — Editor Settings

| Option | Value | Description |
|---|---|---|
| `clipboard` | `unnamedplus` | Yank/paste uses the system clipboard automatically; no `"+y` needed |
| `completeopt` | `menu,menuone,noselect` | Completion menu: show menu, show even with one match, don't auto-select |
| `cursorline` | `true` | Highlights the entire line where the cursor is |
| `expandtab` | `true` | `<Tab>` inserts spaces, not a tab character |
| `hidden` | `true` | Switch buffers without saving; keeps unsaved buffers in memory |
| `ignorecase` | `true` | Case-insensitive search by default |
| `inccommand` | `split` | Preview `:substitute` replacements live in a split as you type |
| `laststatus` | `3` | Single global statusline (not per-window); requires Neovim 0.7+ |
| `mouse` | `a` | Mouse enabled in all modes (normal, insert, visual, command) |
| `number` | `true` | Show absolute line numbers |
| `relativenumber` | `true` | Show relative line numbers alongside absolute; enables `5j`/`3k` jumps |
| `scrolloff` | `8` | Keep 8 lines visible above/below cursor when scrolling |
| `shiftround` | `true` | Round indent to nearest `shiftwidth` multiple when using `<<`/`>>` |
| `shiftwidth` | `2` | 2-space indentation |
| `showmode` | `false` | Hide `-- INSERT --` banner; the statusline handles this |
| `sidescrolloff` | `8` | Keep 8 columns visible left/right of cursor |
| `signcolumn` | `yes` | Always show the sign column; prevents layout shift when LSP adds diagnostics |
| `smartcase` | `true` | Case-sensitive search when query contains uppercase |
| `smartindent` | `true` | Auto-indent new lines based on syntax |
| `splitbelow` | `true` | Horizontal splits open below current window |
| `splitright` | `true` | Vertical splits open to the right |
| `tabstop` | `2` | Tab character displays as 2 spaces wide |
| `termguicolors` | `true` | Enables 24-bit color; required for Catppuccin and most colorschemes |
| `timeoutlen` | `300` | Wait 300 ms for key sequence completion (affects `which-key` popup timing) |
| `undofile` | `true` | Persistent undo history across sessions; stored in `~/.local/share/nvim/undo/` |
| `updatetime` | `200` | Faster CursorHold events; improves LSP hover and gitsigns responsiveness |
| `wrap` | `false` | Long lines don't wrap; scroll horizontally instead |

#### `config/keymaps.lua` — Custom Keybindings

##### Buffer Navigation

| Key | Mode | Action |
|---|---|---|
| `<leader>bd` | Normal | Delete current buffer |
| `<leader>bn` | Normal | Next buffer |
| `<leader>bp` | Normal | Previous buffer |

##### Window Navigation

| Key | Mode | Action | Description |
|---|---|---|---|
| `Ctrl-H` | Normal | Focus window left | Replaces `Ctrl-W h` |
| `Ctrl-J` | Normal | Focus window down | Replaces `Ctrl-W j` |
| `Ctrl-K` | Normal | Focus window up | Replaces `Ctrl-W k` |
| `Ctrl-L` | Normal | Focus window right | Replaces `Ctrl-W l` |
| `Ctrl-←` | Normal | Resize window wider | |
| `Ctrl-→` | Normal | Resize window narrower | |
| `Ctrl-↑` | Normal | Resize window taller | |
| `Ctrl-↓` | Normal | Resize window shorter | |

##### Telescope (Fuzzy Finder)

| Key | Mode | Action |
|---|---|---|
| `<leader>ff` | Normal | Find files in project |
| `<leader>fg` | Normal | Live grep across project |
| `<leader>fb` | Normal | List open buffers |
| `<leader>fh` | Normal | Search help tags |

##### LSP (from `plugins/lsp.lua`)

| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Show hover documentation |

#### `config/autocmds.lua` — Autocommands

| Trigger | Action | Why |
|---|---|---|
| After yank (`TextYankPost`) | Highlights yanked text in `Visual` color for 200 ms | Visual confirmation that yank succeeded |
| Window resize (`VimResized`) | Equalizes all split sizes (`wincmd =`) | Prevents lopsided splits after terminal resize |
| Open `qf`, `help`, `man`, `notify`, `lspinfo`, etc. | Maps `q` to close the buffer | Quick dismiss for utility buffers without `:q<Enter>` |

### Plugins

#### `plugins/colors.lua` — Catppuccin Mocha

| Option | Value | Description |
|---|---|---|
| `flavour` | `mocha` | The darkest Catppuccin variant |
| `transparent_background` | `false` | Solid background (transparency is handled at the terminal level) |
| `show_end_of_buffer` | `true` | Shows `~` for lines after end of file |
| `integrations.cmp` | `true` | Completion menu uses Catppuccin colors |
| `integrations.gitsigns` | `true` | Git gutter signs use Catppuccin colors |
| `integrations.telescope` | `true` | Telescope picker uses Catppuccin colors |
| `integrations.treesitter` | `true` | Treesitter highlights use Catppuccin |
| `integrations.which_key` | `true` | Which-key popup uses Catppuccin |

#### `plugins/lsp.lua` — Language Servers

Configured via `nvim-lspconfig` (included with LazyVim):

| Server | Language | Notable Settings |
|---|---|---|
| `tsserver` | TypeScript / JavaScript | Custom keys: `gd`, `gr`, `K` |
| `pyright` | Python | `diagnosticMode = "workspace"` — checks all files, not just open ones |
| `lua_ls` | Lua | `callSnippet = "Replace"` — completion inserts full call snippet; `checkThirdParty = false` suppresses third-party warnings |

Servers are installed and managed automatically via [Mason](https://github.com/williamboman/mason.nvim).

#### `plugins/telescope.lua` — Fuzzy Finder

| Option | Value | Description |
|---|---|---|
| `layout_config.horizontal.preview_width` | `0.55` | Preview pane takes 55% of the window width |
| `file_ignore_patterns` | `node_modules`, `.git`, `venv`, `.venv`, `__pycache__` | Excluded from all file searches |

#### `plugins/treesitter.lua` — Syntax Highlighting

Treesitter grammars are auto-installed on first use. Pre-pinned grammars:

`bash`, `fish`, `lua`, `python`, `javascript`, `typescript`, `tsx`, `json`, `yaml`, `toml`, `markdown`, `markdown_inline`, `vim`, `vimdoc`

`auto_install = true` means any language opened that has a grammar available will be installed on demand.

### Usage Examples

```vim
" Find a file
<leader>ff

" Search text across the project
<leader>fg

" Go to definition (cursor on a symbol)
gd

" Show hover docs
K

" Sync/update all plugins
:Lazy sync
```

```fish
# Sync plugins headlessly from the shell
nvim --headless "+Lazy! sync" +qa
```

---

## tmux — Terminal Multiplexer

**What it does:** Manages multiple terminal sessions, windows, and panes within a single terminal. Useful when WezTerm's native pane management isn't enough (e.g., remote SSH sessions, session persistence across disconnects).

Config is split into four files sourced from `tmux.conf`:
- `tmux.conf` — core settings, key bindings, plugin declarations
- `statusline.conf` — visual styling (colors, status bar format)
- `utility.conf` — popup bindings (lazygit, btop)
- `macos.conf` — macOS-specific settings (Finder integration, undercurl)

### Configuration Breakdown

#### `tmux.conf` — Core Settings

| Setting | Value | Description |
|---|---|---|
| `default-terminal` | `xterm-256color` | Base terminal type; enables 256 colors |
| `terminal-overrides` | `xterm-256color:Tc` | Enables true color (24-bit) passthrough |
| `repeat-time` | `0` | Disables repeat key delay; bound repeat keys (`-r`) work immediately |
| `focus-events` | `on` | Passes focus in/out events to Neovim; triggers `FocusGained`/`FocusLost` |
| `history-limit` | `64096` | Lines of scrollback per pane (~64K) |
| `escape-time` | `0` | No delay after `Esc`; critical for Neovim — without this, `Esc` in insert mode lags |
| `mode-keys` | `vi` | Copy mode uses vi keys (`v` to select, `y` to yank, etc.) |
| `mouse` | `on` | Click to focus panes, scroll with trackpad |
| `set-titles` | `on` | Updates the terminal window title |
| `set-titles-string` | `#T` | Title is the current pane title (usually the running command) |

#### `statusline.conf` — Visual Styling

Catppuccin-inspired dark palette with hardcoded hex colors:

| Element | Colors | Description |
|---|---|---|
| Status bar background | `#404063` | Dark blue-purple |
| Status bar text | `#586e75` | Muted teal |
| Pane border (inactive) | `#2e2e47` | Dark, low-contrast |
| Pane border (active) | `#eee8d5` | Light cream; highlights focused pane |
| Message / mode indicator | `fg=#eee8d5 bg=#2e2e47` | Command prompt and messages |

**Left status:** `session:window.pane` → `username` — shows context at a glance.

**Right status:** Hostname of the machine.

**Window status (inactive):** `index  current-dir-basename`

**Window status (active):** Gold (`#b58900`) Powerline-style highlight with the basename of the current pane path.

**Status update interval:** Every 1 second (`status-interval 1`).

### Keybindings

**Prefix key:** `Ctrl-B` (tmux default — not remapped)

#### Core

| Key | Action | Description |
|---|---|---|
| `prefix + r` | Reload config | Sources `~/.config/tmux/tmux.conf` and prints "Reloaded!" |
| `prefix + e` | Kill other panes | Prompts confirmation before closing all panes except the current one |
| `Ctrl-Shift-←` | Move window left | Swaps current window with the one to the left |
| `Ctrl-Shift-→` | Move window right | Swaps current window with the one to the right |

#### Pane Splitting (via `tmux-pain-control` plugin)

| Key | Action |
|---|---|
| `prefix + \|` | Split vertically (left/right) |
| `prefix + -` | Split horizontally (top/bottom) |

#### Popup Utilities (`utility.conf`)

| Key | Action | Description |
|---|---|---|
| `prefix + g` | Open lazygit | Full-screen git UI in an 80%×80% popup, rooted in the current pane's directory |
| `prefix + m` | Open btop | Process monitor in an 80%×80% popup |

#### macOS-specific (`macos.conf`)

| Key | Action |
|---|---|
| `prefix + o` | Open current pane's directory in macOS Finder |

### Plugins

| Plugin | Purpose | Status |
|---|---|---|
| `tmux-plugins/tpm` | Plugin manager (Tmux Plugin Manager) | Installed |
| `tmux-plugins/tmux-pain-control` | Adds sane pane splitting/navigation bindings | Installed |
| `tmux-plugins/tmux-resurrect` | Save and restore tmux sessions across reboots | Declared — run `prefix + I` to install |

**Plugin management (inside a tmux session):**

```
prefix + I      # Install new plugins listed in tmux.conf
prefix + U      # Update all installed plugins
```

### Notes

- `escape-time 0` is critical when using Neovim inside tmux. Without it, pressing `Esc` in insert mode causes a ~500 ms delay.
- Once `tmux-resurrect` is installed: `prefix + Ctrl-S` to save, `prefix + Ctrl-R` to restore.

---

## Starship — Prompt

**What it does:** A cross-shell, fast prompt written in Rust. Shows only relevant context (git branch, Python version, cloud profile, etc.) and hides irrelevant modules.

Config: `~/.config/starship/starship.toml`

### Prompt Layout

```
[user@host] directory  branch [status] [aws:profile] [gcp:config] [python] [node] ⏱duration
❯
```

`add_newline = false` keeps the prompt on one line with the preceding output.

### Configuration Breakdown

#### Directory

| Option | Value | Description |
|---|---|---|
| `style` | `blue` | Directory shown in blue |
| `truncation_length` | `3` | Show at most 3 path components |
| `truncate_to_repo` | `true` | Truncate to the repo root when inside a git repo |
| `fish_style_pwd_dir_length` | `1` | Abbreviates parent path components to their first letter (fish-shell style) |

Example: `/Users/admin/projects/my-api` inside a git repo rooted at `my-api` → `~/p/my-api`

#### Git

| Module | Symbol | Description |
|---|---|---|
| `git_branch` | ` ` (nerd font branch) | Shows current branch in bold cyan |
| `git_status` | Various Unicode | Wrapped in `[]`; combined into one indicator |

Git status symbols:

| Symbol | Meaning |
|---|---|
| `?` | Untracked files |
| `!` | Modified files |
| `+` | Staged files |
| `»` | Renamed files |
| `✘` | Deleted files |
| `≡` | Stashed changes |
| `⇡` | Ahead of remote |
| `⇣` | Behind remote |
| `⇕` | Diverged from remote |
| `✖` | Merge conflicts |

#### Languages

| Module | Trigger files | Format |
|---|---|---|
| `python` | `requirements.txt`, `pyproject.toml`, `.python-version`, `uv.lock`, `*.py` | ` <version>` in yellow |
| `nodejs` | `package.json`, `.node-version`, `.nvmrc` | ` <version>` in green |

Languages are only shown when the current directory contains the relevant trigger files — no noise in non-project directories.

#### Cloud & Infrastructure

| Module | Condition | Format |
|---|---|---|
| `aws` | `AWS_PROFILE` env var is set | ` <profile>(<region>)` in yellow |
| `gcloud` | Active gcloud config exists | ` gcp:<config>` in blue |

AWS uses `force_display = false` — the module is hidden unless `AWS_PROFILE` is set (typically via direnv `.envrc`).

#### Command Duration

| Option | Value | Description |
|---|---|---|
| `min_time` | `500` ms | Only show duration for commands that take more than 500 ms |
| `format` | `⏱ <duration>` | Dimmed white; unobtrusive |

#### Username and Hostname

| Module | Condition | Why |
|---|---|---|
| `username` | `show_always = false` | Only shown when SSH'd in or running as root |
| `hostname` | `ssh_only = true` | Only shown in SSH sessions |

This keeps the prompt clean on local machines while clearly showing context on remote servers.

#### Prompt Character

| State | Symbol | Color |
|---|---|---|
| Success (exit 0) | `❯` | Bold green |
| Error (exit ≠ 0) | `❯` | Bold red |

---

## direnv — Per-directory Environment

**What it does:** Automatically loads and unloads environment variables when entering/leaving directories containing an `.envrc` file. Avoids polluting the global shell environment.

### Custom `direnvrc` Extensions

`~/.config/direnv/direnvrc` adds two custom layouts that extend direnv's stdlib:

#### `layout uv` — Python (uv)

Used in `.envrc` as:
```sh
layout uv
```

What it does:
1. Creates `.venv/` in the project root if it doesn't exist (using `uv venv`)
2. Sets `VIRTUAL_ENV` to `.venv/`
3. Adds `.venv/bin` to `PATH`
4. Exports `UV_ACTIVE=1`

This integrates with `pyinit` — running `pyinit 3.12` writes `layout uv` into `.envrc` automatically.

#### `use node` — Node.js (fnm)

Used in `.envrc` as:
```sh
use node        # reads version from .node-version
use node 20     # explicit version
```

What it does:
1. Reads the target version from the argument or `.node-version`
2. Finds the Node binary directory via `fnm exec`
3. If the version isn't installed, runs `fnm install` automatically
4. Adds the versioned Node binaries to `PATH`
5. Exports `NODE_VERSION`

### Usage Examples

```sh
# Python project
echo "layout uv" > .envrc
direnv allow
# → .venv created, activated automatically on cd

# Node project
echo "use node" > .envrc
direnv allow
# → Node version from .node-version activated on cd

# Set project-specific AWS credentials
cat >> .envrc <<EOF
export AWS_PROFILE=my-project
export AWS_DEFAULT_REGION=ap-southeast-1
EOF
direnv allow
```

### Notes

- Always run `direnv allow` after creating or modifying `.envrc`.
- `.direnv/` should be added to `.gitignore` (included in the general template).
- direnv only runs `.envrc` files you have explicitly allowed — untrusted files are blocked.

---

## git — Templates

**What it does:** Stores `.gitignore` templates used by the `gitinit` function. Templates are merged at project init time, not applied globally.

Templates live in `~/.config/git/templates/`:

| File | Used for |
|---|---|
| `general.gitignore` | Always merged in; covers macOS, editors, env files, secrets |
| `python.gitignore` | Python-specific: `.venv/`, `__pycache__/`, `dist/`, `.pytest_cache/`, etc. |
| `node.gitignore` | Node-specific: `node_modules/`, `.next/`, `dist/`, `.cache/`, etc. |

### `general.gitignore` — Always Included

| Category | Patterns |
|---|---|
| macOS | `.DS_Store`, `.AppleDouble`, `.LSOverride` |
| Editors | `.idea/`, `.vscode/`, `*.swp`, `*.swo`, `*~` |
| Environment | `.env`, `.env.*` (but not `.env.example`) |
| direnv | `.direnv/` |
| Secrets/certs | `*.pem`, `*.key`, `*.p12` |
| Logs | `*.log` |
| Temp files | `*.bak`, `*.orig`, `*.tmp` |

### Usage

```fish
# Initialize a Python project with git
gitinit python

# Initialize a Node project and create a private GitHub repo
gitinit node --github

# General .gitignore only
gitinit general
```

---

## Tips for Customization

### Machine-specific configuration (fish)

Copy the example file and add secrets/overrides:

```fish
~/.config/fish/conf.d/config-local.fish
```

This file is never tracked by git. Use it for `ANTHROPIC_API_KEY`, `AWS_PROFILE`, workspace paths, etc.

### Adding a new fish alias or abbreviation

Edit the source file via chezmoi:

```fish
chezmoi edit ~/.config/fish/conf.d/aliases.fish
chezmoi apply
```

Use `abbr` for commands where tab completion on arguments matters (e.g., git). Use `alias` for simple substitutions.

### Changing the Neovim colorscheme

Edit `~/.config/nvim/lua/plugins/colors.lua` and change `flavour`:

```lua
flavour = "mocha",  -- options: latte, frappe, macchiato, mocha
```

### Adding a new Neovim plugin

Create a new file in `~/.config/nvim/lua/plugins/` — LazyVim auto-imports all files from that directory:

```lua
-- ~/.config/nvim/lua/plugins/my-plugin.lua
return {
  "author/plugin-name",
  opts = {},
}
```

### Adding a new tmux keybinding

Add to `~/.config/tmux/utility.conf` and reload with `prefix + r`:

```tmux
bind x run-shell "some-command"
```

### Changing WezTerm font or size

Edit `wezterm.lua` — WezTerm hot-reloads the config automatically on save:

```lua
config.font = wezterm.font("Hack Nerd Font Mono")
config.font_size = 13.0
```

### Adjusting Starship modules

Disable a module entirely:

```toml
[nodejs]
disabled = true
```

Force the AWS module to always display (even without `AWS_PROFILE`):

```toml
[aws]
force_display = true
```
