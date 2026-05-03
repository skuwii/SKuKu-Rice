// STR — Palette
//
// STR brand backbone: bg #0e0f11, surface #1c1e21, azure #2980d4 — these
// remain locked. Warm tones (peach / yellow / pink / green) were previously
// neutralised; the user has opened them back up for *semantic* use only —
// pink hearts, yellow moons, peach suns, green charging indicators.
// Honda Red stays mostly reserved for critical alerts and the topbar power
// button, but light accent use elsewhere is now allowed.
//
// No /tmp/qs_colors.json reader — palette is locked regardless of wallpaper.
// Property names match ilyamiro's MatugenColors so widgets keep compiling.

import QtQuick

Item {
    id: root

    // ── Neutrals (cold, the STR backbone) ────────────────────
    property color crust:    "#0e0f11"  // STR bg
    property color mantle:   "#131418"  // 1 step lift
    property color base:     "#1c1e21"  // STR surface
    property color surface0: "#25272a"  // surface-2
    property color surface1: "#2e3136"  // line
    property color surface2: "#3a3d42"

    property color overlay0: "#4f5258"  // text-mute
    property color overlay1: "#6a6d72"
    property color overlay2: "#8a8d92"  // text-dim

    property color subtext0: "#a8abaf"
    property color subtext1: "#c2c4c8"
    property color text:     "#d6d8dc"  // STR text

    // ── Azure scale (primary accent — STR's voice) ────────────
    property color blue:     "#2980d4"  // STR azure
    property color sapphire: "#4ea0e8"  // azure-hi
    property color teal:     "#1f5e9a"  // azure-dim
    property color mauve:    "#5b8fc4"  // cool blue-violet (kept cold)

    // ── Honda Red (critical + sparing accents) ────────────────
    property color red:      "#c0392b"  // Honda Red
    property color maroon:   "#c0392b"

    // ── Semantic warm tones ───────────────────────────────────
    // Reserved for icons whose meaning is intrinsically warm — not for
    // generic accents. Avoid recoloring whole UI regions with these.
    //   peach  → sun, warm weather, daylight
    //   yellow → moon, idle, low-attention
    //   pink   → hearts, favorites, music album hints
    //   green  → charging, online, success
    property color peach:    "#fab387"
    property color yellow:   "#f9e2af"
    property color pink:     "#ffb8c6"
    property color green:    "#a6e3a1"

    // Kept for binding compatibility with the matugen reader pattern.
    property string rawJson: ""
}
