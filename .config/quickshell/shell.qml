import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Widgets


ShellRoot {
    id: root

    GlobalConfig {
        id: config
    }

    GlobalHelper {
        id: helper
    }

    PanelWindow {
        id: panel

        implicitWidth: column.implicitWidth

        color: config.background

        anchors {
            left:   true
            top:    true
            bottom: true
        }

        ColumnLayout {
            id: column

            anchors.fill: parent

            spacing: config.panelPadding

            PanelFocus {
                Layout.fillHeight: true
            }

            PanelWorkspaces {
                Layout.preferredHeight: implicitHeight
            }

            PanelCalendar {
                Layout.preferredHeight: implicitHeight
            }
        }
    }

    component GlobalConfig: Item {
        readonly property color  foreground:       "#abb2bf"
        readonly property color  foregroundDark:   "#848b98"
        readonly property color  foregroundDarker: "#5f6571"
        readonly property color  background:       "#23272e"
        readonly property color  backgroundLight:  "#31353f"

        readonly property int    panelWorkspace:    5
        readonly property int    panelPadding:      4

        readonly property int    iconSize:          28

        readonly property string fontFamily:       "Cantarell"
        readonly property int    fontSize:          12
    }

    component GlobalHelper: Item {
        id: root

        readonly property date date:             subClock.date

        readonly property var  monitors:         Hyprland.monitors
        readonly property var  workspaces:       Hyprland.workspaces
        readonly property var  toplevels:        Hyprland.toplevels
        readonly property var  focusedMonitor:   Hyprland.focusedMonitor
        readonly property var  focusedWorkspace: Hyprland.focusedWorkspace
        readonly property var  activeToplevel:   Hyprland.activeToplevel

        readonly property int  workspaceId:      focusedWorkspace?.id ?? 1

        function getIcon(desc) {
            const trial = Quickshell.iconPath(desc, true);

            if (trial.length > 0)
                return trial;

            return Quickshell.iconPath("image-missing", true);
        }

        function fmtDate(fmt: string): string {
            return Qt.formatDateTime(date, fmt);
        }

        function dispatch(request: string): void {
            Hyprland.dispatch(request);
        }

        SystemClock {
            id: subClock

            precision: SystemClock.Seconds
        }

        Connections {
            target: Hyprland

            function onRawEvent(event: HyprlandEvent): void {
                if (event.name.endsWith("v2"))
                    return;

                if (event.name.includes("mon"))
                    Hyprland.refreshMonitors();
                else if (event.name.includes("workspace"))
                    Hyprland.refreshWorkspaces();
                else
                    Hyprland.refreshToplevels();
            }
        }
    }

    component PanelFocus: Item {
        id: root

        implicitWidth: Math.max(subIcon.implicitWidth, subText.implicitHeight) +
                       config.panelPadding * 2

        property string icon:  helper.getIcon("")
        property string text: "Desktop"

        Column {
            id: subColumn

            IconImage {
                id: subIcon

                implicitSize: config.iconSize

                source: root.icon
            }

            Text {
                id: subText

                color: config.foreground

                font.family:    config.fontFamily
                font.pointSize: config.fontSize

                transform: Rotation {
                    angle: 90

                    origin.x: subText.implicitHeight / 2
                    origin.y: subText.implicitHeight / 2
                }

                text: root.text
            }
        }

        TextMetrics {
            id: subMetrics

            font.family:    config.fontFamily
            font.pointSize: config.fontSize

            elide:      Qt.ElideRight
            elideWidth: root.height - subIcon.height

            onTextChanged: {
                root.text = elidedText;
                root.icon = helper.getIcon(helper.activeToplevel?.lastIpcObject.class ?? "");
            }

            text: helper.activeToplevel?.title ?? qsTr("Desktop")
        }
    }

    component PanelWorkspace: Item {
        id: root

        width:  config.iconSize
        height: config.iconSize

        required property int  index
        required property var  occupation

        readonly property bool occupied: occupation[index] ?? false

        Text {
            anchors.centerIn: root

            font.family:    config.fontFamily
            font.pointSize: config.fontSize

            text:  root.index + 1
            color: root.occupied ?
                       config.foreground :
                       config.foregroundDarker

            MouseArea {
                anchors.fill: parent

                acceptedButtons: Qt.LeftButton

                onClicked: {
                    helper.dispatch(`vdesk ${index + 1}`)
                }
            }
        }
    }

    component PanelWorkspaces: Item {
        id: root

        implicitWidth:  subColumn.implicitWidth
        implicitHeight: subColumn.implicitHeight

        readonly property var occupation: {
            helper.workspaces.values.reduce((a, c) => {
                a[c.id] = c.lastIpcObject.windows > 0;
                return a;
            }, {})
        }

        ColumnLayout {
            id: subColumn

            spacing: 0

            Repeater {
                model: config.panelWorkspace

                PanelWorkspace {
                    occupation: root.occupation
                }
            }
        }
    }

    component PanelCalendar: Item {
        id: root

        implicitWidth:  subText.implicitWidth
        implicitHeight: subText.implicitHeight

        Text {
            id: subText

            color: config.foreground

            font.family:    config.fontFamily
            font.pointSize: config.fontSize

            anchors.horizontalCenter: parent.horizontalCenter

            text: helper.fmtDate("hh:mm")
        }
    }
}
