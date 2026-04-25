local wezterm = require("wezterm")
local act     = wezterm.action

-- ── Leader ────────────────────────────────────────────────
-- All pane/tab bindings are prefixed with Ctrl-t

local leader = { key = "t", mods = "CTRL", timeout_milliseconds = 1000 }

-- ── Keys ──────────────────────────────────────────────────

local keys = {
	-- Pane: split (tmux-style)
	{ key = "%", mods = "LEADER",       action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = '"', mods = "LEADER",       action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "w", mods = "LEADER",       action = act.CloseCurrentPane({ confirm = true }) },

	-- Pane: navigate (hjkl or arrows)
	{ key = "h",          mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "j",          mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	{ key = "k",          mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "l",          mods = "LEADER", action = act.ActivatePaneDirection("Right") },
	{ key = "LeftArrow",  mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "DownArrow",  mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	{ key = "UpArrow",    mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "RightArrow", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

	-- Pane: resize
	{ key = "H", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Left",  3 }) },
	{ key = "J", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Down",  3 }) },
	{ key = "K", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Up",    3 }) },
	{ key = "L", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Right", 3 }) },

	-- Tab: open / cycle / jump
	{ key = "c", mods = "LEADER",       action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "n", mods = "LEADER",       action = act.ActivateTabRelative(1) },
	{ key = "p", mods = "LEADER",       action = act.ActivateTabRelative(-1) },
	{ key = "1", mods = "LEADER",       action = act.ActivateTab(0) },
	{ key = "2", mods = "LEADER",       action = act.ActivateTab(1) },
	{ key = "3", mods = "LEADER",       action = act.ActivateTab(2) },
	{ key = "4", mods = "LEADER",       action = act.ActivateTab(3) },
	{ key = "5", mods = "LEADER",       action = act.ActivateTab(4) },
	{ key = "6", mods = "LEADER",       action = act.ActivateTab(5) },
	{ key = "7", mods = "LEADER",       action = act.ActivateTab(6) },
	{ key = "8", mods = "LEADER",       action = act.ActivateTab(7) },
	{ key = "9", mods = "LEADER",       action = act.ActivateTab(8) },

	-- Scroll
	{ key = "u",        mods = "LEADER",      action = act.ScrollByPage(-0.5) },
	{ key = "d",        mods = "LEADER",      action = act.ScrollByPage(0.5) },
	{ key = "PageUp",   mods = "LEADER",      action = act.ScrollToTop },
	{ key = "PageDown", mods = "LEADER",      action = act.ScrollToBottom },
	{ key = "l",        mods = "LEADER|CTRL", action = act.ClearScrollback("ScrollbackAndViewport") },

	-- Clear scrollback
	{ key = "k", mods = "CMD", action = act.ClearScrollback("ScrollbackAndViewport") },

	-- Window: fullscreen / minimize / transparency
	{ key = "Enter", mods = "CMD", action = act.ToggleFullScreen },
	{
		key = "m", mods = "CMD",
		action = wezterm.action_callback(function(window, pane)
			if window:get_dimensions().is_full_screen then
				window:perform_action(act.ToggleFullScreen, pane)
			else
				window:perform_action(act.Hide, pane)
			end
		end),
	},
	{
		key = "u", mods = "CMD",
		action = wezterm.action_callback(function(window, _)
			local ov = window:get_config_overrides() or {}
			ov.window_background_opacity = ov.window_background_opacity == 0.85 and 1.0 or 0.85
			window:set_config_overrides(ov)
		end),
	},
}

-- ── Mouse ─────────────────────────────────────────────────

local mouse_bindings = {
	{ event = { Down = { streak = 1, button = "Right" } }, mods = "CTRL", action = act.CopyTo("Clipboard") },
}

local selection_word_boundary = " \t\n{}[]()\"'`,;:"

-- ──────────────────────────────────────────────────────────

return {
	leader                 = leader,
	keys                   = keys,
	mouse_bindings         = mouse_bindings,
	selection_word_boundary = selection_word_boundary,
}
