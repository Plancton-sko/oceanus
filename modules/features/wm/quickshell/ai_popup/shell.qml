import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

Scope {
    id: root

    property string homeDir: Quickshell.env("HOME")
    readonly property string fontName: "FiraCode Nerd Font"

    property string clipboardContent: ""
    property var aiActions: [
        {
            title: "Claude Code",
            cmd: "uwsm app -- ghostty -e claude",
            desc: "Launch interactive Claude terminal assistant"
        },
        {
            title: "Strix Assistant",
            cmd: "uwsm app -- ghostty -e strix",
            desc: "Launch Strix fast LLM agent"
        },
        {
            title: "Explain Clipboard",
            cmd: "ghostty --class=ghostty.floating -e fish -c 'wl-paste | bat; read'",
            desc: "View and inspect current clipboard buffer"
        },
        {
            title: "Nix Package Search",
            cmd: "uwsm app -- ghostty -e fish -c 'read -p \"echo Search Nix package: \" pkg; nix search nixpkgs $pkg; read'",
            desc: "Quickly query NixOS package database"
        }
    ]

    property int selectedIndex: 0
    signal requestClose

    Theme {
        id: theme
    }

    IpcHandler {
        function close() {
            root.requestClose();
        }
        target: "ai_popup"
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: win

                required property var modelData
                property bool isClosing: false
                property real animOffsetY: -10
                property real animOpacity: 0

                function closePopup() {
                    if (isClosing)
                        return;
                    isClosing = true;
                    exitAnim.start();
                }

                screen: modelData
                exclusionMode: PanelWindow.ExclusionMode.Ignore
                focusable: true
                color: "transparent"
                implicitWidth: 320
                implicitHeight: 240

                Component.onCompleted: {
                    introAnim.start();
                }

                Connections {
                    function onRequestClose() {
                        win.closePopup();
                    }
                    target: root
                }

                anchors {
                    top: true
                    left: true
                }

                margins {
                    top: win.animOffsetY + 32
                    left: 32
                }

                ParallelAnimation {
                    id: introAnim
                    NumberAnimation {
                        target: win
                        property: "animOffsetY"
                        from: -10
                        to: 4
                        duration: 100
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: win
                        property: "animOpacity"
                        from: 0
                        to: 1
                        duration: 100
                        easing.type: Easing.OutCubic
                    }
                }

                ParallelAnimation {
                    id: exitAnim
                    onStopped: Qt.quit()
                    NumberAnimation {
                        target: win
                        property: "animOffsetY"
                        from: 4
                        to: -10
                        duration: 80
                        easing.type: Easing.InCubic
                    }
                    NumberAnimation {
                        target: win
                        property: "animOpacity"
                        from: 1
                        to: 0
                        duration: 80
                        easing.type: Easing.InCubic
                    }
                }

                HyprlandFocusGrab {
                    active: !win.isClosing
                    windows: [win]
                    onCleared: win.closePopup()
                }

                Rectangle {
                    anchors.fill: parent
                    opacity: win.animOpacity
                    color: theme.popupBgColor
                    border.width: 1
                    border.color: theme.accent
                    radius: 0
                    focus: true

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) {
                            win.closePopup();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Up) {
                            if (root.selectedIndex > 0)
                                root.selectedIndex--;
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Down) {
                            if (root.selectedIndex < root.aiActions.length - 1)
                                root.selectedIndex++;
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (root.selectedIndex >= 0 && root.selectedIndex < root.aiActions.length) {
                                Quickshell.execDetached(["sh", "-c", root.aiActions[root.selectedIndex].cmd]);
                                win.closePopup();
                            }
                            event.accepted = true;
                        }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8

                        // Header
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Text {
                                text: "󰧑"
                                renderType: Text.NativeRendering
                                color: theme.accent
                                font.family: root.fontName
                                font.pixelSize: 14
                            }

                            Text {
                                text: "AI & Developer Assistant"
                                renderType: Text.NativeRendering
                                color: theme.fg
                                font.family: root.fontName
                                font.pixelSize: 11
                                font.bold: true
                                Layout.fillWidth: true
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: theme.bg_light
                        }

                        // Actions List
                        ListView {
                            id: actionList
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            model: root.aiActions
                            clip: true
                            spacing: 4

                            delegate: Rectangle {
                                width: actionList.width
                                height: 36
                                color: (root.selectedIndex === index) ? Qt.rgba(theme.accent.r, theme.accent.g, theme.accent.b, 0.15) : "transparent"
                                border.width: (root.selectedIndex === index) ? 1 : 0
                                border.color: theme.accent

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    spacing: 2

                                    Text {
                                        text: modelData.title
                                        renderType: Text.NativeRendering
                                        color: (root.selectedIndex === index) ? theme.accent : theme.fg
                                        font.family: root.fontName
                                        font.pixelSize: 10
                                        font.bold: true
                                    }

                                    Text {
                                        text: modelData.desc
                                        renderType: Text.NativeRendering
                                        color: theme.fg_light
                                        font.family: root.fontName
                                        font.pixelSize: 8
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: root.selectedIndex = index
                                    onClicked: {
                                        Quickshell.execDetached(["sh", "-c", modelData.cmd]);
                                        win.closePopup();
                                    }
                                }
                            }
                        }

                        // Footer hint
                        Text {
                            text: "[ENTER] Select  |  [ESC] Close"
                            renderType: Text.NativeRendering
                            color: theme.bg_light
                            font.family: root.fontName
                            font.pixelSize: 8
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }
    }
}
