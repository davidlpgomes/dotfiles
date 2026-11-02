-- Hyprland config (notebook)
-- Docs: https://wiki.hypr.land/configuring/
--
-- Synced with the PC config. Lines marked "NOTEBOOK" intentionally differ from the PC.

------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/configuring/core/monitors/

-- NOTEBOOK: built-in display + HDMI mirrored
hl.monitor({ output = "eDP-1", mode = "1920x1080@120", position = "0x0", scale = 1.25 })
hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto", scale = 1.25, mirror = "eDP-1" })
-- hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto-right", scale = 1 })

-- Workspace rules, see https://wiki.hypr.land/configuring/core/rules/workspace-rules/
-- NOTEBOOK: eDP-1 / HDMI-A-1
hl.workspace_rule({ workspace = "1", monitor = "eDP-1", default = true })
for _, ws in ipairs({ "2", "3", "4", "5", "6", "7" }) do
	hl.workspace_rule({ workspace = ws, monitor = "eDP-1" })
end

for _, ws in ipairs({ "8", "9", "10" }) do
	hl.workspace_rule({ workspace = ws, monitor = "HDMI-A-1" })
end

---------------------
---- MY PROGRAMS ----
---------------------

local terminal = "ghostty"
local fileManager = "nautilus"
local fileManagerTerminal = "yazi"
local browser = "zen-browser"
local audio = "wiremix"
local bluetooth = "bluetui"
local menu = "rofi -show drun"

-- Opens a TUI app in a floating terminal (matched by the "terminal-float" window rule below)
local function floatTerm(cmd)
	return terminal .. " --title=terminal-float -e " .. cmd
end

-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/configuring/core/autostart/
hl.on("hyprland.start", function()
	-- Clipboard
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")

	-- GNOME Keyring
	hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")

	-- Status bar
	hl.exec_cmd("ironbar")

	-- Notification daemon (dunst)
	hl.exec_cmd("dunst")

	-- Polkit Agent
	hl.exec_cmd("systemctl --user start hyprpolkitagent")

	-- Wallpaper
	hl.exec_cmd("hyprpaper")

	-- XDGDP
	hl.exec_cmd("~/scripts/xdgdp")

	-- Dark mode
	hl.exec_cmd('gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3-dark"')
	hl.exec_cmd('gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"')
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/configuring/core/environment-variables/

-- Cursor
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- NOTEBOOK: no Nvidia variables

hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

hl.env("SSH_AUTH_SOCK", (os.getenv("XDG_RUNTIME_DIR") or "") .. "/ssh-agent.socket")

-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/configuring/core/config-options/
hl.config({
	general = {
		gaps_in = 0,
		gaps_out = 0,
		border_size = 0,
		allow_tearing = false,
		layout = "dwindle",
	},
	decoration = {
		rounding = 0,
		rounding_power = 1.0,
		-- Change transparency of focused and unfocused windows
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		shadow = {
			enabled = false,
			range = 4,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},
		blur = {
			enabled = false,
			size = 3,
			passes = 1,
			vibrancy = 0.1696,
		},
	},
	animations = {
		enabled = true,
	},
	dwindle = {
		preserve_split = true,
	},
	misc = {
		focus_on_activate = true,
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
	},
	xwayland = {
		force_zero_scaling = true,
	},
})

-- Curves and animations, see https://wiki.hypr.land/configuring/core/animations/
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

---------------
---- INPUT ----
---------------

-- NOTEBOOK: ABNT2 keyboard and touchpad settings
hl.config({
	input = {
		kb_layout = "br",
		kb_variant = "abnt2",
		kb_model = "",
		kb_options = "",
		kb_rules = "",

		follow_mouse = 2,

		sensitivity = 0,

		touchpad = {
			natural_scroll = true,
		},
	},
})

-- See https://wiki.hypr.land/configuring/core/binds/gestures/
hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

---------------------
---- KEYBINDINGS ----
---------------------

-- See https://wiki.hypr.land/configuring/core/binds/
local mainMod = "SUPER"
local secMod = "SUPER + SHIFT"

hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(floatTerm(audio)))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(floatTerm(bluetooth)))
hl.bind(secMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(floatTerm(fileManagerTerminal)))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("zeditor"))
hl.bind(secMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(browser))
hl.bind(secMod .. " + H", hl.dsp.exec_cmd(floatTerm("ssh -t nous 'bash -lic hermes'")))
hl.bind(secMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
-- Note: with a Lua config, "hyprctl dispatch" takes Lua, so "exit" became 'hl.dsp.exit()'
hl.bind(
	mainMod .. " + M",
	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("obsidian"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(menu))
-- NOTEBOOK: GTK_IM_MODULE=simple for the ABNT2 dead keys
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("env GTK_IM_MODULE=simple " .. terminal))

-- Toggle light/dark theme
hl.bind(
	secMod .. " + T",
	hl.dsp.exec_cmd([[
if gsettings get org.gnome.desktop.interface color-scheme | grep -q "dark"; then
    gsettings set org.gnome.desktop.interface color-scheme "prefer-light"
    gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3"
else
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3-dark"
fi]])
)

hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(secMod .. " + V", hl.dsp.window.pin({ action = "toggle" }))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(floatTerm("impala")))

-- Zen mode
hl.bind(
	mainMod .. " + Z",
	hl.dsp.exec_cmd([[
if [ -f /tmp/hypr-zenmode ]; then
    rm /tmp/hypr-zenmode && ironbar bar main show && ironbar bar side show
else
    touch /tmp/hypr-zenmode && ironbar bar main hide && ironbar bar side hide
fi]])
)
-- Restart, not "ironbar reload": in 0.19.1 reload leaves the old scripts running
hl.bind(secMod .. " + Z", hl.dsp.exec_cmd("rm -f /tmp/hypr-zenmode; pkill -x ironbar; ironbar"))

-- Move focus with mainMod + H/J/K/L
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness (bindel = repeating + locked)
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl (bindl = locked)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Screenshot
hl.bind("Print", hl.dsp.exec_cmd('grim -g "$(slurp -d)" - | wl-copy'))

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/configuring/core/rules/window-rules/

hl.window_rule({
	name = "terminal-float",
	match = { initial_title = "terminal-float" },

	float = true,
	center = true,
	size = "1200 800",
})

hl.window_rule({
	name = "xdg-portal-float",
	match = { class = "xdg-desktop-portal-gtk" },

	float = true,
	center = true,
	size = "1200 800",
})

hl.window_rule({
	-- Ignore maximize requests from all apps. You'll probably like this.
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})

hl.window_rule({
	-- Fix some dragging issues with XWayland
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

-- Hyprland-run windowrule
hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },

	move = "20 monitor_h-120",
	float = true,
})
