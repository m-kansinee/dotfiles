local wezterm = require("wezterm")
local c       = require("palette")

-- ── Powerline characters ──────────────────────────────────
local R    = utf8.char(0xe0b0)  -- ▶ solid right
local L    = utf8.char(0xe0b2)  -- ◀ solid left
local Rs   = utf8.char(0xe0b1)  -- ▷ thin right (inactive tab separator)
local CLOCK  = utf8.char(0xf017)  -- nf-fa-clock

local BATTERY = {
	utf8.char(0xf244),  -- empty  (  0–24%)
	utf8.char(0xf243),  -- low    ( 25–49%)
	utf8.char(0xf242),  -- half   ( 50–74%)
	utf8.char(0xf241),  -- high   ( 75–89%)
	utf8.char(0xf240),  -- full   ( 90–100%)
}
local function battery_icon(pct)
	if     pct >= 90 then return BATTERY[5]
	elseif pct >= 75 then return BATTERY[4]
	elseif pct >= 50 then return BATTERY[3]
	elseif pct >= 25 then return BATTERY[2]
	else                  return BATTERY[1]
	end
end

-- ── Helpers ───────────────────────────────────────────────

-- Transition arrow: fg=src (shape color), bg=dst (new background)
local function arrow(src, dst, ch)
	return {
		{ Background = { Color = dst } },
		{ Foreground = { Color = src } },
		{ Text = ch },
	}
end

-- Text segment with optional bold
local function seg(bg, fg, text, bold)
	local t = {
		{ Background = { Color = bg } },
		{ Foreground = { Color = fg } },
	}
	if bold then t[#t + 1] = { Attribute = { Intensity = "Bold" } } end
	t[#t + 1] = { Text = text }
	return t
end

-- Flatten a list of format-element arrays into one
local function flatten(list)
	local out = {}
	for _, t in ipairs(list) do
		for _, v in ipairs(t) do out[#out + 1] = v end
	end
	return out
end

-- ── Tab titles ────────────────────────────────────────────

wezterm.on("format-tab-title", function(tab, tabs, _, _, _, max_width)
	local pane_title = (tab.active_pane and tab.active_pane.title) or ""
	local title = (tab.tab_title and #tab.tab_title > 0) and tab.tab_title or pane_title
	title = title:gsub(".*[/\\](.*)", "%1")

	local idx      = tostring(tab.tab_index + 1)
	local is_last  = tab.tab_index == #tabs - 1
	local next_tab = tabs[tab.tab_index + 2]  -- tab_index is 0-based; Lua tables are 1-based

	if tab.is_active then
		-- overhead: [▶] + " idx " + ▶ + " " + " " + ▶
		local overhead = (tab.tab_index > 0 and 1 or 0) + #idx + 6
		title = wezterm.truncate_right(title, math.max(1, max_width - overhead))
		local parts = {}
		if tab.tab_index > 0 then
			parts[#parts + 1] = arrow(c.bar_bg, c.index_bg, R)
		end
		parts[#parts + 1] = seg(c.index_bg, c.index_fg, " " .. idx .. " ", true)
		parts[#parts + 1] = arrow(c.index_bg, c.title_bg, R)
		parts[#parts + 1] = seg(c.title_bg, c.title_fg, " " .. title .. " ", false)
		parts[#parts + 1] = arrow(c.title_bg, c.bar_bg, R)
		return flatten(parts)
	else
		-- overhead: " idx  title " + [▷]
		local has_sep = not is_last and not (next_tab and next_tab.is_active)
		local overhead = #idx + 4 + (has_sep and 1 or 0)
		title = wezterm.truncate_right(title, math.max(1, max_width - overhead))
		local fmt = seg(c.bar_bg, c.bar_fg, " " .. idx .. "  " .. title .. " ", false)
		if has_sep then
			fmt[#fmt + 1] = { Background = { Color = c.bar_bg } }
			fmt[#fmt + 1] = { Foreground = { Color = c.bar_fg } }
			fmt[#fmt + 1] = { Text = Rs }
		end
		return fmt
	end
end)

-- ── Right status ──────────────────────────────────────────
-- fullscreen: ◀[battery]◀[time]◀[hostname]
-- normal:            ◀◀◀[hostname]

local hostname = wezterm.hostname():gsub("%..*", "")

wezterm.on("update-right-status", function(window, _)
	local is_fs = window:get_dimensions().is_full_screen
	local parts = {}

	if is_fs then
		local battery = ""
		for _, b in ipairs(wezterm.battery_info()) do
			local pct = math.floor(b.state_of_charge * 100)
			battery = string.format(" %s %d%% ", battery_icon(pct), pct)
		end
		if battery ~= "" then
			parts[#parts + 1] = arrow(c.mid1_bg, c.bar_bg, L)
			parts[#parts + 1] = seg(c.mid1_bg, c.user_fg, battery, false)
			parts[#parts + 1] = arrow(c.mid2_bg, c.mid1_bg, L)
		else
			parts[#parts + 1] = arrow(c.mid1_bg, c.bar_bg, L)
			parts[#parts + 1] = arrow(c.mid2_bg, c.mid1_bg, L)
		end
		parts[#parts + 1] = seg(c.mid2_bg, c.user_fg, " " .. CLOCK .. " " .. wezterm.strftime("%H:%M") .. " ", false)
		parts[#parts + 1] = arrow(c.user_bg, c.mid2_bg, L)
	else
		parts[#parts + 1] = arrow(c.mid1_bg, c.bar_bg,  L)
		parts[#parts + 1] = arrow(c.mid2_bg, c.mid1_bg, L)
		parts[#parts + 1] = arrow(c.user_bg, c.mid2_bg, L)
	end

	parts[#parts + 1] = seg(c.user_bg, c.user_fg, " " .. hostname .. " ", true)
	window:set_right_status(wezterm.format(flatten(parts)))
end)
