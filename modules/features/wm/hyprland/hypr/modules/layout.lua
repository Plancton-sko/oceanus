hl.config({
	general = {
		layout = "scrolling",
	},
	scrolling = {
		column_width = 0.6,
		follow_focus = true,
		direction = "right",
		fullscreen_on_one_column = true,
		wrap_focus = false,
		wrap_swapcol = false,
	},
	dwindle = {
		preserve_split = true,
	},
})

local colors = {}
local colors_status, c = pcall(require, "modules.colors")
if colors_status then
	colors = c
end
