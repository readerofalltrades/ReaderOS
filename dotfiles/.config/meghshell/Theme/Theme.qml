pragma Singleton
import Quickshell
import QtQuick

Singleton {
    readonly property color background:       "#0d1117"
    readonly property color surface:          "#161b22"
    readonly property color surfaceContainer: "#1c2128"
    readonly property color surfaceBorder:    "#30363d"

    readonly property color fgSurface:  "#e6edf3"
    readonly property color fgMuted:    "#8b949e"
    readonly property color fgDim:      "#484f58"
    readonly property color fgPrimary:  "#d29922"

    readonly property color primary:   "#d29922"
    readonly property color secondary: "#388bfd"

    readonly property int spacing:    8
    readonly property int spacingLg:  16
    readonly property int spacingSm:  4

    readonly property int radius:   12
    readonly property int radiusSm: 6
    readonly property int radiusPill: 999

    readonly property int animDuration: 220
    readonly property int animDurationFast: 120

    readonly property string fontMono: "JetBrains Mono"
    readonly property string fontUi:   "Inter"
    readonly property string fontIcon: "Symbols Nerd Font"

    readonly property int barHeight: 36
    readonly property int barPadding: 6
}
