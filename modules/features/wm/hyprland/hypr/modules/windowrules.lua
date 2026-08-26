--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
hl.window_rule({
	name = "suppress-maximize-events",
	match = {
		class = ".*",
	},
	suppress_event = "maximize",
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

hl.window_rule({
	name = "satty-float",
	match = {
		class = "satty",
	},
	float = true,
	size = { 800, 400 },
	center = true,
})

hl.window_rule({
	name = "thunar-floating",
	match = {
		class = "^thunar$",
	},
	float = true,
	size = { 1000, 650 },
	center = true,
})

hl.window_rule({
	name = "ghostty-floating",
	match = {
		class = "ghostty.floating",
		title = ".+",
	},
	float = true,
	size = { 1000, 600 },
	center = true,
})

hl.layer_rule({
	name = "quickshell-blur",
	match = {
		namespace = "quickshell",
	},
	animation = "slide left",
	blur = true,
	ignore_alpha = 0.01,
})

hl.layer_rule({
	name = "waybar-blur",
	match = {
		namespace = "waybar",
	},
	animation = "slide left",
	blur = true,
	ignore_alpha = 0.01,
})

hl.layer_rule({
	name = "osd-blur",
	match = {
		namespace = "osd",
	},
	animation = "slide top",
	blur = true,
	ignore_alpha = 0.01,
})

hl.layer_rule({
	name = "mako-blur",
	match = {
		namespace = "notifications",
	},
	blur = true,
	animation = "slide top",
	ignore_alpha = 0.01,
})

-- Dedicated Workspaces
hl.window_rule({
	name = "gaming-workspace",
	match = {
		class = "^([Ss]team|[Ll]utris|[Hh]eroic)$",
	},
	workspace = "8",
})

-- Special Scratchpads
hl.window_rule({
	name = "music-scratchpad",
	match = {
		class = "^[Ss]potify$",
	},
	workspace = "special:music",
	float = true,
	size = { 1400, 850 },
	center = true,
})

hl.window_rule({
	name = "notes-scratchpad",
	match = {
		class = "^[Oo]bsidian$",
	},
	workspace = "special:notes",
	float = true,
	size = { 1400, 900 },
	center = true,
})

-- Full Opacity Overrides
hl.window_rule({
	name = "qemu-kvm-opacity",
	match = {
		class = "^(virt-manager|[Qq]emu.*)$",
	},
	opacity = "1.0 override 1.0 override",
})

-- Browser starting width in scrolling layout
hl.window_rule({
	name = "firefox-starting-width",
	match = {
		class = "^firefox.*$",
	},
	scrolling_width = 0.7,
})
