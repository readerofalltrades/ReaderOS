import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import qs.Theme

PanelWindow {
    id: root

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Theme.barHeight + Theme.barPadding * 2
    color: "transparent"
    WlrLayershell.exclusionMode: ExclusionMode.Auto
    WlrLayershell.layer: WlrLayer.Top

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    // Volume
    Process {
        id: volumeProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var text = data.toString().trim()
                var match = text.match(/Volume:\s*([\d.]+)/)
                if (match) volumeValue = Math.round(parseFloat(match[1]) * 100)
                volumeMuted = text.indexOf("MUTED") !== -1
            }
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: volumeProc.running = true
    }

    property int volumeValue: 0
    property bool volumeMuted: false

    // Brightness
    Process {
        id: brightnessProc
        command: ["brightnessctl", "-m"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var text = data.toString().trim()
                var parts = text.split(",")
                if (parts.length >= 4) {
                    var pct = parts[3].replace("%", "")
                    brightnessValue = parseInt(pct)
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: brightnessProc.running = true
    }

    property int brightnessValue: 0

    // Battery
    Process {
        id: batteryCapProc
        command: ["cat", "/sys/class/power_supply/BAT1/capacity"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var val = parseInt(data.toString().trim())
                if (!isNaN(val)) batteryValue = val
            }
        }
    }

    Process {
        id: batteryStatusProc
        command: ["cat", "/sys/class/power_supply/BAT1/status"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                batteryCharging = data.toString().trim() === "Charging"
            }
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: {
            batteryCapProc.running = true
            batteryStatusProc.running = true
        }
    }

    property int batteryValue: 0
    property bool batteryCharging: false

    // Network
    Process {
        id: networkProc
        command: ["nmcli", "-t", "-f", "active,ssid", "dev", "wifi"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var text = data.toString().trim()
                var lines = text.split("\n")
                networkSsid = ""
                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split(":")
                    if (parts[0] === "yes") {
                        networkSsid = parts[1] || ""
                        break
                    }
                }
            }
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: networkProc.running = true
    }

    property string networkSsid: ""

    // Left island
    Rectangle {
        id: leftIsland
        anchors.left: parent.left
        anchors.leftMargin: Theme.barPadding
        anchors.verticalCenter: parent.verticalCenter
        height: Theme.barHeight
        implicitWidth: leftRow.implicitWidth + Theme.spacingLg * 2
        radius: Theme.radiusPill
        color: Theme.surface

        Row {
            id: leftRow
            anchors.centerIn: parent
            spacing: Theme.spacing

            Repeater {
                model: Hyprland.workspaces

                delegate: Rectangle {
                    required property var modelData
                    property bool isActive: Hyprland.focusedMonitor
                        && Hyprland.focusedMonitor.activeWorkspace
                        && modelData.id === Hyprland.focusedMonitor.activeWorkspace.id

                    anchors.verticalCenter: parent.verticalCenter
                    height: 8
                    width: isActive ? 22 : 8
                    radius: Theme.radiusPill
                    color: isActive ? Theme.primary : Theme.fgDim

                    Behavior on width {
                        NumberAnimation {
                            duration: Theme.animDuration
                            easing.type: Easing.InOutQuad
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Hyprland.dispatch("workspace " + modelData.id)
                    }
                }
            }

            Rectangle {
                width: 1
                height: 14
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.fgDim
                visible: windowTitle.text !== ""
            }

            Text {
                id: windowTitle
                anchors.verticalCenter: parent.verticalCenter
                text: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : ""
                color: Theme.fgMuted
                font.family: Theme.fontUi
                font.pixelSize: 13
                elide: Text.ElideRight
                maximumLineCount: 1
                visible: text !== ""
            }
        }
    }

    // Center island
    Rectangle {
        id: centerIsland
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        height: Theme.barHeight
        implicitWidth: centerRow.implicitWidth + Theme.spacingLg * 2
        radius: Theme.radiusPill
        color: Theme.surface

        Row {
            id: centerRow
            anchors.centerIn: parent
            spacing: Theme.spacing

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Qt.formatTime(clock.date, "hh:mm")
                color: Theme.fgSurface
                font.family: Theme.fontMono
                font.pixelSize: 14
                font.weight: Font.Medium
            }

            Rectangle {
                width: 1
                height: 14
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.fgDim
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Qt.formatDate(clock.date, "ddd, MMM d")
                color: Theme.fgMuted
                font.family: Theme.fontUi
                font.pixelSize: 13
            }
        }
    }

    // Right island
    Rectangle {
        id: rightIsland
        anchors.right: parent.right
        anchors.rightMargin: Theme.barPadding
        anchors.verticalCenter: parent.verticalCenter
        height: Theme.barHeight
        implicitWidth: rightRow.implicitWidth + Theme.spacingLg * 2
        radius: Theme.radiusPill
        color: Theme.surface

        Row {
            id: rightRow
            anchors.centerIn: parent
            spacing: Theme.spacing

            // Volume
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.volumeMuted ? "󰝟" : root.volumeValue >= 50 ? "󰕾" : "󰖀"
                color: root.volumeMuted ? Theme.fgDim : Theme.fgMuted
                font.family: Theme.fontIcon
                font.pixelSize: 14
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.volumeMuted ? "mute" : root.volumeValue + "%"
                color: Theme.fgMuted
                font.family: Theme.fontUi
                font.pixelSize: 13
            }

            Rectangle {
                width: 1
                height: 14
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.fgDim
            }

            // Brightness
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.brightnessValue >= 70 ? "󰃠" : root.brightnessValue >= 30 ? "󰃟" : "󰃞"
                color: Theme.fgMuted
                font.family: Theme.fontIcon
                font.pixelSize: 14
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.brightnessValue + "%"
                color: Theme.fgMuted
                font.family: Theme.fontUi
                font.pixelSize: 13
            }

            Rectangle {
                width: 1
                height: 14
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.fgDim
            }

            // Battery
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.batteryCharging ? "󰂄" :
                      root.batteryValue >= 90 ? "󰁹" :
                      root.batteryValue >= 70 ? "󰂀" :
                      root.batteryValue >= 50 ? "󰁾" :
                      root.batteryValue >= 30 ? "󰁼" :
                      root.batteryValue >= 15 ? "󰁺" : "󰂃"
                color: root.batteryValue <= 15 && !root.batteryCharging ? "#f85149" : Theme.fgMuted
                font.family: Theme.fontIcon
                font.pixelSize: 14
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.batteryValue + "%"
                color: root.batteryValue <= 15 && !root.batteryCharging ? "#f85149" : Theme.fgMuted
                font.family: Theme.fontUi
                font.pixelSize: 13
            }

            Rectangle {
                width: 1
                height: 14
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.fgDim
            }

            // Network
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.networkSsid !== "" ? "󰤨" : "󰤭"
                color: root.networkSsid !== "" ? Theme.fgMuted : Theme.fgDim
                font.family: Theme.fontIcon
                font.pixelSize: 14
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.networkSsid !== "" ? root.networkSsid : "offline"
                color: root.networkSsid !== "" ? Theme.fgMuted : Theme.fgDim
                font.family: Theme.fontUi
                font.pixelSize: 13
            }

            Rectangle {
                width: 1
                height: 14
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.fgDim
            }

            // Notifications button
            Rectangle {
                width: 24
                height: 24
                radius: Theme.radiusSm
                color: notifHover.containsMouse ? Theme.surfaceContainer : "transparent"
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    text: "󰂚"
                    color: Theme.fgMuted
                    font.family: Theme.fontIcon
                    font.pixelSize: 14
                }

                MouseArea {
                    id: notifHover
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: console.log("notifications toggle")
                }
            }

            // Sidebar button
            Rectangle {
                width: 24
                height: 24
                radius: Theme.radiusSm
                color: sidebarHover.containsMouse ? Theme.surfaceContainer : "transparent"
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    text: "󰄝"
                    color: Theme.fgMuted
                    font.family: Theme.fontIcon
                    font.pixelSize: 14
                }

                MouseArea {
                    id: sidebarHover
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: console.log("sidebar toggle")
                }
            }

            // Power button
            Rectangle {
                width: 24
                height: 24
                radius: Theme.radiusSm
                color: powerHover.containsMouse ? "#3d1f1f" : "transparent"
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    text: "󰐥"
                    color: powerHover.containsMouse ? "#f85149" : Theme.fgMuted
                    font.family: Theme.fontIcon
                    font.pixelSize: 14
                }

                MouseArea {
                    id: powerHover
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: console.log("power toggle")
                }
            }
        }
    }
}
