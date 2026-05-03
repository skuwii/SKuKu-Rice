// STR — Locked Palette
//
// Replaces ilyamiro's matugen-driven Catppuccin theme with the strict STR
// brand palette: bg #0e0f11, surface #1c1e21, azure #2980d4, Honda Red #c0392b.
// No /tmp/qs_colors.json reader — the palette stays fixed regardless of
// wallpaper. Property names are kept identical to the original so every widget
// that imports `MatugenColors` keeps compiling without edits.
//
// Honda Red discipline: `red` and `maroon` map to #c0392b but should ONLY be
// referenced in critical-state code paths (battery critical, power button).
// Any decorative usage of `red` in a ported widget needs to be swapped to a
// neutral STR token at port time.

import QtQuick

Item {
    id: root

    // ── Neutrals (cold, no warm tones) ──────────────────────
    property color crust:    "#0e0f11"  // STR bg
    property color mantle:   "#131418"  // 1 step lift from bg
    property color base:     "#1c1e21"  // STR surface
    property color surface0: "#25272a"  // STR surface-2
    property color surface1: "#2e3136"  // STR line
    property color surface2: "#3a3d42"

    property color overlay0: "#4f5258"  // STR text-mute
    property color overlay1: "#6a6d72"
    property color overlay2: "#8a8d92"  // STR text-dim

    property color subtext0: "#a8abaf"
    property color subtext1: "#c2c4c8"
    property color text:     "#d6d8dc"  // STR text

    // ── Azure scale (the only saturated color group) ────────
    property color blue:     "#2980d4"  // STR azure (THE accent)
    property color sapphire: "#4ea0e8"  // STR azure-hi
    property color teal:     "#1f5e9a"  // STR azure-dim — re-used as cooler teal
    property color mauve:    "#5b8fc4"  // cool blue-violet kept on the cold axis

    // ── Critical-only (Honda Red) ───────────────────────────
    // Only legitimate uses: battery critical, power-button accents, alerts.
    property color red:      "#c0392b"
    property color maroon:   "#c0392b"

    // ── Warm tones in the source theme remap to neutrals ────
    // STR brand spec: no warm tones anywhere. These exist so widgets that
    // reference `peach`/`yellow`/`pink`/`green` keep compiling, but they
    // resolve to neutral STR text tones — the visual impact disappears.
    property color peach:    "#8a8d92"
    property color yellow:   "#8a8d92"
    property color pink:     "#5b8fc4"
    property color green:    "#4ea0e8"

    // The original matugen reader exposed `rawJson` so other widgets could
    // observe theme reloads. Kept as an empty constant for binding safety.
    property string rawJson: ""
}
