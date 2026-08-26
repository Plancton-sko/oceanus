-------------------
---- AUTOSTART ----
-------------------

local dotfiles = os.getenv("WABI_DOTFILES_DIR") or "/home/plancton/dev/rice/nixos/doty"

hl.on("hyprland.start", function()
	-- System Startups
	hl.exec_cmd(dotfiles .. "/modules/scripts/theme_switcher restore")
	hl.exec_cmd("hyprctl setcursor capitaine-cursors 24")
	hl.exec_cmd("uwsm app -- udiskie --tray --notify")

	-- Quickshell surfaces
	hl.exec_cmd(
		"sh -lc 'if command -v quickshell >/dev/null 2>&1; then uwsm app -- quickshell --config osd; elif command -v qs >/dev/null 2>&1; then uwsm app -- qs --config osd; fi'"
	)
	hl.exec_cmd(
		"sh -lc 'if command -v quickshell >/dev/null 2>&1; then uwsm app -- quickshell --config workspace_overview; elif command -v qs >/dev/null 2>&1; then uwsm app -- qs --config workspace_overview; fi'"
	)

	-- Single entry point for waybar + quickshell widgets
	hl.exec_cmd("~/.config/waybar/scripts/toggle_widgets restore")
	hl.exec_cmd(
		"sh -c '"
			.. dotfiles
			.. '/modules/scripts/set_wallpaper "$(cat ~/.cache/last_wallpaper 2>/dev/null || echo "'
			.. dotfiles
			.. '/modules/backgrounds/gray_lien.jpg")"\''
	)
	hl.exec_cmd("uwsm app -- hyprsunset")
	hl.exec_cmd("uwsm app -- wl-paste --type text --watch cliphist store")
	hl.exec_cmd("uwsm app -- wl-paste --type image --watch cliphist store")
	hl.exec_cmd("systemctl --user start hyprpolkitagent")
	hl.exec_cmd("systemctl --user start ssh-agent.service")
end)
