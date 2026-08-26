---------------------
---- Keybindings ----
---------------------
local mainMod = "SUPER"
local terminal = "uwsm app -- ghostty"
local fileManager = "uwsm app -- thunar"
local osdctl = os.getenv("HOME") .. "/.config/quickshell/osd/bin/osdctl"

---------------------
---  Applications ---
---------------------

-- Terminal
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + RETURN", hl.dsp.exec_cmd("uwsm app -- ghostty --class=ghostty.floating"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))

-- Web Browser (Firefox)
hl.bind(
	mainMod .. " + B",
	hl.dsp.exec_cmd(
		"hyprctl clients | grep -iq 'class: .*firefox' && hyprctl dispatch 'hl.dsp.focus({ window = \"class:^firefox.*\" })' || uwsm app -- firefox"
	)
)

-- Code / Cursor Editor
hl.bind(
	mainMod .. " + semicolon",
	hl.dsp.exec_cmd(
		"hyprctl clients | grep -iq 'class: .*cursor' && hyprctl dispatch 'hl.dsp.focus({ window = \"class:^cursor.*\" })' || uwsm app -- cursor"
	)
)
hl.bind(
	mainMod .. " + ALT + semicolon",
	hl.dsp.exec_cmd(
		"hyprctl clients | grep -Eiq 'class: code$' && hyprctl dispatch 'hl.dsp.focus({ window = \"class:^[Cc]ode$\" })' || uwsm app -- code"
	)
)

-- Music Surface (Spotify on special:music)
hl.bind(
	mainMod .. " + M",
	hl.dsp.exec_cmd(
		"hyprctl clients | grep -iq 'class: .*spotify' && hyprctl dispatch 'hl.dsp.workspace.toggle_special(\"music\")' || (uwsm app -- spotify & hyprctl dispatch 'hl.dsp.workspace.toggle_special(\"music\")')"
	)
)

-- Notes Surface (Obsidian on special:notes)
hl.bind(
	mainMod .. " + N",
	hl.dsp.exec_cmd(
		"hyprctl clients | grep -iq 'class: .*obsidian' && hyprctl dispatch 'hl.dsp.workspace.toggle_special(\"notes\")' || (uwsm app -- obsidian & hyprctl dispatch 'hl.dsp.workspace.toggle_special(\"notes\")')"
	)
)

-- Gaming Launcher (Steam on workspace 8)
hl.bind(
	mainMod .. " + G",
	hl.dsp.exec_cmd(
		"hyprctl clients | grep -iq 'class: .*steam' && hyprctl dispatch 'hl.dsp.focus({ workspace = 8 })' || (uwsm app -- steam & hyprctl dispatch 'hl.dsp.focus({ workspace = 8 })')"
	)
)

---------------------
---    Windows    ---
---------------------

hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(
	mainMod .. " + C",
	hl.dsp.window.float({
		action = "toggle",
	})
)
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())

-- Move/resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), {
	mouse = true,
})
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), {
	mouse = true,
})

-- Resize with keyboard (Arrow keys)
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true })

---------------------
---    Layout     ---
---------------------

hl.bind(mainMod .. " + J", hl.dsp.layout("promote"))

-- Focus with arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

---------------------
---  Workspaces   ---
---------------------

-- Switch/move workspaces [1-0]
for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

---------------------
---  Quickshell   ---
---------------------

hl.bind(
	mainMod .. " + SPACE",
	hl.dsp.exec_cmd(
		"quickshell -c apps_popup ipc call apps_popup close || (quickshell -c recents_popup ipc call recents_popup close; quickshell --config apps_popup)"
	)
)
hl.bind(
	mainMod .. " + TAB",
	hl.dsp.exec_cmd(
		"quickshell -c recents_popup ipc call recents_popup close || (quickshell -c apps_popup ipc call apps_popup close; quickshell --config recents_popup)"
	)
)
hl.bind(
	mainMod .. " + X",
	hl.dsp.exec_cmd("quickshell -c power_popup ipc call power_popup close || quickshell --config power_popup")
)
hl.bind(
	mainMod .. " + V",
	hl.dsp.exec_cmd(
		"quickshell -c clipboard_popup ipc call clipboard_popup close || quickshell --config clipboard_popup"
	)
)
hl.bind(
	mainMod .. " + K",
	hl.dsp.exec_cmd("quickshell -c shortcut_popup ipc call shortcut_popup close || quickshell --config shortcut_popup")
)

---------------------
---   Screenshots ---
---------------------

local ss_dir = "$HOME/Pictures/Screenshots"
local ss_path = ss_dir .. "/Screenshot_$(date '+%Y-%m-%d_%H.%M.%S').png"
local grimhyprctl = "grim -o \"$(hyprctl activeworkspace -j | jq -r '.monitor')\""
local slurp_cmd = "slurp -b \\#1d2021b0 -c \\#d5c4a1ff -s \\#00000000"

local save_register_ss = "mkdir -p " .. ss_dir .. " && FILE=" .. ss_path .. " && " .. grimhyprctl .. ' "$FILE" && wl-copy < "$FILE" && notify-send -t 2000 -i "$FILE" -a "Screenshot" "Screenshot Saved" "Copied to clipboard"'
local save_register_ss_region_swappy = "mkdir -p " .. ss_dir .. " && FILE=" .. ss_path .. ' && grim -g "$(' .. slurp_cmd .. ')" "$FILE" && swappy -f "$FILE" -o "$FILE" && notify-send -t 2000 -i "$FILE" -a "Screenshot" "Screenshot Saved" "Copied to clipboard"'

hl.bind("Print", hl.dsp.exec_cmd("sh -c '" .. save_register_ss .. "'"), { locked = true })
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("sh -c '" .. save_register_ss_region_swappy .. "'"))

---------------------
---    System     ---
---------------------

hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock -c ~/.config/hypr/hyprlock.conf"))

-- Laptop / Media Keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(osdctl .. " volume up"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(osdctl .. " volume down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(osdctl .. " volume mute"), { locked = true, repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
