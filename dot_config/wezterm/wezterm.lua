local wezterm = require("wezterm")
local config = {}

local c = require("palette")
local kb = require("keybindings")
require("statusbar")

-- ── Performance ───────────────────────────────────────────
-- WebGpu is recommended on macOS for best performance
config.front_end = "WebGpu"
config.max_fps = 60
config.animation_fps = 30

-- ── Font ──────────────────────────────────────────────────
config.font = wezterm.font("Hack Nerd Font Mono")
config.font_size = 13.0

-- ── Appearance ────────────────────────────────────────────
config.color_scheme = "Catppuccin Mocha"
config.window_decorations = "RESIZE" -- add TITLE to restore macOS titlebar
config.window_close_confirmation = "NeverPrompt"
config.scrollback_lines = 10000
config.default_cursor_style = "BlinkingBar"
config.window_background_opacity = 1.0
config.window_padding = { left = 4, right = 4, top = 4, bottom = 4 }
config.audible_bell = "Disabled"
config.initial_rows = 40
config.initial_cols = 120

-- ── Tab bar ───────────────────────────────────────────────
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = false
config.colors = {
	tab_bar = {
		background = c.bar_bg,
		active_tab = { bg_color = c.bar_bg, fg_color = c.bar_fg },
		inactive_tab = { bg_color = c.bar_bg, fg_color = c.bar_fg },
		inactive_tab_hover = { bg_color = c.bar_bg, fg_color = c.bar_fg },
		new_tab = { bg_color = c.bar_bg, fg_color = c.bar_fg },
		new_tab_hover = { bg_color = c.bar_bg, fg_color = c.bar_fg },
	},
}

-- ── Keybindings ───────────────────────────────────────────
config.leader = kb.leader
config.keys = kb.keys
config.mouse_bindings = kb.mouse_bindings
config.selection_word_boundary = kb.selection_word_boundary

return config
