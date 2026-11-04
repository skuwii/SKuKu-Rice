-- STR Hyprland config (Lua, Hyprland >= 0.57)
-- API reference: /usr/share/hypr/stubs/hl.meta.lua

local home = os.getenv("HOME")
local hyprDir = home .. "/.config/hypr"
local qsDir = hyprDir .. "/scripts/quickshell"
local dotScripts = home .. "/.dotfiles/scripts"

local terminal = "kitty"
local fileManager = "thunar"
local mod = "SUPER"

local function qsToggle(widget)
    return hl.dsp.exec_cmd("bash " .. hyprDir .. "/scripts/qs_manager.sh toggle " .. widget)
end

----------------
--- MONITORS ---
----------------
hl.monitor({ output = "eDP-1", mode = "1920x1080@144", position = "0x0", scale = 1, vrr = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto", scale = 1, mirror = "eDP-1" })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1, mirror = "eDP-1" })

-------------------
--- ENVIRONMENT ---
-------------------
-- The Intel GPU drives the display. Don't set GBM_BACKEND, __GLX_VENDOR_LIBRARY_NAME
-- or LIBVA_DRIVER_NAME to nvidia here: every client then loads NVIDIA's EGL against
-- an Intel render node. Use prime-run for apps that need the dGPU.
hl.env("WALLPAPER_DIR", home .. "/media/wallpapers")
hl.env("XCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("__GL_GSYNC_ALLOWED", "1")
hl.env("__GL_VRR_ALLOWED", "1")

-----------------
--- AUTOSTART ---
-----------------
hl.on("hyprland.start", function()
    -- Bluetooth is soft-blocked at boot otherwise, which breaks the panel toggle
    hl.exec_cmd("rfkill unblock bluetooth")

    -- Regenerate the palette cache and set the flag before Quickshell reads it
    hl.exec_cmd("wal -i " .. home .. "/media/wallpapers/firewatch.jpg -n -q && echo wal > /tmp/qs_theme_mode")

    hl.exec_cmd("quickshell -p " .. qsDir .. "/Main.qml")
    hl.exec_cmd("quickshell -p " .. qsDir .. "/TopBar.qml")
    hl.exec_cmd("quickshell -p " .. qsDir .. "/Floating.qml")
    hl.exec_cmd("quickshell -p " .. qsDir .. "/LeftPanel.qml")
    hl.exec_cmd("quickshell -p " .. qsDir .. "/OSD.qml")
    hl.exec_cmd("quickshell -p " .. qsDir .. "/RecordingIndicator.qml")

    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("awww img " .. home .. "/media/wallpapers/firewatch.jpg --transition-type none")
    hl.exec_cmd("kitty --class dropdown")
    hl.exec_cmd("paplay " .. home .. "/.dotfiles/sounds/login.ogg")
    hl.exec_cmd("bash " .. qsDir .. "/music/qs_cava.sh")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd(home .. "/.dotfiles/hypr/battery-alert.sh")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("easyeffects --gapplication-service")
    -- Plugin options only exist once the plugin is loaded, so reload after hyprpm finishes
    hl.exec_cmd("hyprpm reload -n && hyprctl reload config-only")
    hl.exec_cmd(dotScripts .. "/workspace-wallpaper-daemon.sh")
end)

---------------------
--- LOOK AND FEEL ---
---------------------
hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
        col = {
            active_border = { colors = { "rgba(2980d4ff)", "rgba(2980d433)" }, angle = 45 },
            inactive_border = "rgba(1c1e21aa)",
        },
        resize_on_border = true,
        allow_tearing = true,
        layout = "dwindle",
    },

    decoration = {
        rounding = 10,
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 0.95,
        shadow = {
            enabled = true,
            range = 20,
            render_power = 3,
            color = "rgba(00000040)",
        },
        blur = {
            enabled = true,
            size = 6,
            passes = 3,
            vibrancy = 0.2,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        mouse_move_enables_dpms = true,
        -- Lets a crashed or frozen lock be restarted from a TTY instead of rebooting
        allow_session_lock_restore = true,
    },

    input = {
        kb_layout = "us",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = true,
        },
    },
})

-- STR branded curves
hl.curve("strSnap", { type = "bezier", points = { { 0.2, 1.0 }, { 0.3, 1.0 } } })   -- windows: fast settle, precise
hl.curve("strSlide", { type = "bezier", points = { { 0.4, 0.0 }, { 0.6, 1.0 } } })  -- workspaces: clean directional
hl.curve("strFade", { type = "bezier", points = { { 0.05, 0.0 }, { 0.1, 1.0 } } })  -- exits + fades
hl.curve("linear", { type = "bezier", points = { { 0.0, 0.0 }, { 1.0, 1.0 } } })

hl.animation({ leaf = "global", enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "windows", enabled = true, speed = 3.5, bezier = "strSnap" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3.5, bezier = "strSnap", style = "popin 85%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.5, bezier = "strFade", style = "popin 85%" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2.5, bezier = "strSlide", style = "slide" })
hl.animation({ leaf = "fade", enabled = true, speed = 2.5, bezier = "strFade" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "linear", style = "loop" })

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-------------------
--- KEYBINDINGS ---
-------------------
hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + E", hl.dsp.exit())
hl.bind(mod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + SPACE", qsToggle("applauncher"))
hl.bind(mod .. " + M", hl.dsp.window.move({ workspace = "special" }))
hl.bind(mod .. " + SHIFT + M", hl.dsp.workspace.toggle_special())

-- Scratchpad workspaces
hl.bind(mod .. " + 7", hl.dsp.workspace.toggle_special("music"))
hl.bind(mod .. " + 8", hl.dsp.workspace.toggle_special("notes"))
hl.bind(mod .. " + 9", hl.dsp.workspace.toggle_special("calc"))
hl.bind(mod .. " + grave", hl.dsp.workspace.toggle_special("dropdown"))

hl.bind(mod .. " + SHIFT + R", hl.dsp.reload_config())
hl.bind(mod .. " + SHIFT + R", hl.dsp.exec_cmd(dotScripts .. "/recording-stop.sh"))

-- Focus
hl.bind(mod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Workspaces 1-6: switch, and move window
for i = 1, 6 do
    hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i, follow = true }))
end

-- Scroll workspaces
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Screenshots: Quickshell overlay (select + annotate + QR scan)
hl.bind("Print", hl.dsp.exec_cmd(dotScripts .. "/qs-screenshot.sh"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd(dotScripts .. "/qs-screenshot.sh"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(
    'grim ~/media/screenshots/$(date +%Y%m%d_%H%M%S).png && notify-send "Screenshot" "Full screen saved" -t 2000'
))

hl.bind("SUPER + C", hl.dsp.exec_cmd("hyprpicker -a"))

-- Quickshell widgets
hl.bind("SUPER + B", qsToggle("clipboard"))
hl.bind("SUPER + A", qsToggle("volume"))
hl.bind("SUPER + S", qsToggle("sysmon"))
hl.bind(mod .. " + W", qsToggle("wallpaper"))
hl.bind(mod .. " + N", qsToggle("network"))
hl.bind(mod .. " + SHIFT + T", hl.dsp.exec_cmd(dotScripts .. "/toggle-theme.sh"))

-- Lock: hyprlock (Lock.qml exists but is retired; security-critical, keep the battle-tested one)
hl.bind(mod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))

-- Media keys, routed through osd-trigger.sh to show the OSD overlay
local osd = dotScripts .. "/osd-trigger.sh "
local heldKey = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(osd .. "volume up"), heldKey)
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(osd .. "volume down"), heldKey)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(osd .. "volume mute"), heldKey)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(osd .. "brightness up"), heldKey)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(osd .. "brightness down"), heldKey)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-------------
--- RULES ---
-------------
-- Glassmorphism on the Quickshell popup layer
hl.layer_rule({
    name = "qs-blur",
    match = { namespace = "qs-popups" },
    blur = true,
})

hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "dropdown-terminal",
    match = { class = "dropdown" },
    float = true,
    move = "0 0",
    size = "monitor_w monitor_h*0.4",
    workspace = "special:dropdown",
})

hl.window_rule({
    name = "scratchpad-music",
    match = { class = "Spotify" },
    workspace = "special:music",
})

hl.window_rule({
    name = "scratchpad-notes",
    match = { class = "obsidian" },
    workspace = "special:notes",
})

hl.window_rule({
    name = "scratchpad-calc",
    match = { class = "scratchpad-calc" },
    float = true,
    size = "620 400",
    center = true,
    workspace = "special:calc",
})

---------------
--- PLUGINS ---
---------------
local function pluginLoaded(name)
    for _, plugin in ipairs(hl.get_loaded_plugins()) do
        if plugin.name == name then
            return true
        end
    end
    return false
end

if pluginLoaded("hyprbars") then
    hl.config({
        plugin = {
            hyprbars = {
                bar_height = 18,
                bar_color = "rgba(0e0f1133)",
                col = { text = "rgba(d6d8dc55)" },
                bar_text_size = 9,
                bar_text_font = "JetBrainsMono Nerd Font",
                bar_padding = 4,
                bar_button_padding = 5,
                bar_precedence_over_border = true,
                buttons = {
                    button_size = 8,
                    col = {
                        close = "rgba(c0392b66)",
                        minimize = "rgba(8a8d9244)",
                        maximize = "rgba(2980d444)",
                    },
                },
            },
        },
    })
end

if pluginLoaded("dynamic-cursors") then
    hl.config({
        plugin = {
            ["dynamic-cursors"] = {
                enabled = true,
                mode = "tilt",
                threshold = 2,
                tilt = {
                    limit = 5000,
                    ["function"] = "negative_quadratic",
                },
                shake = {
                    enabled = true,
                    threshold = 6.0,
                    factor = 1.5,
                    expand_effect = true,
                },
            },
        },
    })
end
