------------------
---- MONITORS ----
------------------
-- Primary: 1920x1080@144 Hz
-- Secondary: 1360x768@60 Hz

hl.monitor({
	output = "DP-1",
	mode = "1920x1080@144",
	position = "0x0",
	scale = "1",
})

hl.monitor({
	output = "HDMI-A-1",
	mode = "1360x768@60",
	position = "1920x156",
	scale = "1",
})

-- Fallback for unconfigured monitors
hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = "1",
})
