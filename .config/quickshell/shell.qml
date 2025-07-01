import Qt.labs.folderlistmodel

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import Quickshell.Widgets

import "root:/fuzzy.js" as Fuzzy


ShellRoot {
    id: root

    component CustomWindow: PanelWindow {
        property string name: "default"

        WlrLayershell.namespace: `quickshell-${name}`

        color: "transparent"
    }

    component CustomShortcut: GlobalShortcut {
        appid: "quickshell"
    }

    component GlobalConfig: Item {
        readonly property color  foreground:       "#abb2bf"
        readonly property color  foregroundDark:   "#848b98"
        readonly property color  foregroundDarker: "#5f6571"
        readonly property color  background:       "#23272e"
        readonly property color  backgroundLight:  "#31353f"

        readonly property string fontFamily:       "Cantarell"
        readonly property int    fontSize:          10
        readonly property int    fontSizeLarge:     12

        readonly property int    panelWidth:        48
        readonly property int    panelWorkspace:    5
        readonly property int    panelPadding:      4
        readonly property int    panelPaddingLarge: 12

        readonly property int    iconSize:          20
        readonly property int    iconSizeLarge:     28
        readonly property int    iconSizeHuge:      42

        readonly property int    menuWidth:         320
        readonly property int    menuEntryHeight:   20
        readonly property int    menuPadding:       4

        readonly property int    launcherWidth:     640
        readonly property int    launcherHeightApp: 48
        readonly property int    launcherHeightInp: 24
        readonly property int    launcherPadding:   4
        readonly property int    launcherApp:       8
    }

    component GlobalHelper: Item {
        id: root

        function getIcon(desc) {
            const trial = Quickshell.iconPath(desc, true);

            if (trial.length > 0)
                return trial;

            return Quickshell.iconPath("image-missing", true);
        }

        SystemClock {
            id: subClock

            precision: SystemClock.Seconds
        }

        readonly property date date: subClock.date

        function fmtDate(fmt: string): string {
            return Qt.formatDateTime(date, fmt);
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

        readonly property var  monitors:         Hyprland.monitors
        readonly property var  workspaces:       Hyprland.workspaces
        readonly property var  toplevels:        Hyprland.toplevels
        readonly property var  focusedMonitor:   Hyprland.focusedMonitor
        readonly property var  focusedWorkspace: Hyprland.focusedWorkspace
        readonly property var  activeToplevel:   Hyprland.activeToplevel

        readonly property int  workspaceId:      focusedWorkspace?.id ?? 1

        function dispatch(request: string): void {
            Hyprland.dispatch(request);
        }

        readonly property var  rawApplications: {
            DesktopEntries.applications.values.filter(a => !a.noDisplay).sort((a, b) =>
                a.name.localeCompare(b.name))
        }
        readonly property var  fuzApplications: {
            rawApplications.map(a => ({
                name:    Fuzzy.prepare(a.name),
                comment: Fuzzy.prepare(a.comment),
                entry:   a
            }))
        }

        function getApp(str: string): var {
            return Fuzzy.go(str, fuzApplications, {
                all:     true,
                keys:  ["name", "comment"],
                scoreFn: r => r[0].score > 0 ? (r[0].score * 0.9 + r[1].score * 0.1) : 0
            }).map(r => r.obj.entry)
        }

        function launch(entry: DesktopEntry): void {
            let exec = entry.execString.split(" ").filter(a => !a.startsWith("%"))

            if (entry.execString.startsWith("sh -c"))
                Quickshell.execDetached(exec.slice(2));
            else
                Quickshell.execDetached(exec);
        }

        /*
        signal startAreaPickerRequested(bool freeze)

        function startAreaPicker(freeze: bool): void {
            startAreaPickerRequested(freeze);
        }
        */
    }

    GlobalConfig {
        id: config
    }

    GlobalHelper {
        id: helper

        /*
        onStartAreaPickerRequested: freeze => {
            root.areaPickerFreeze = freeze;
            root.areaPickerActive = true;
        }
        */
    }

    CustomShortcut {
        name:        "screenshot"
        description: "Take screenshot"

        onPressed: helper.startAreaPicker(false)
    }

    CustomShortcut {
        name:        "screenshotFreeze"
        description: "Take screenshot (freeze mode)"

        onPressed: helper.startAreaPicker(true)
    }

    component PanelFocus: Item {
        id: root

        implicitWidth:  config.panelWidth
        implicitHeight: subColumn.height

        property string icon:  helper.getIcon("")
        property string text: "Desktop"

        Column {
            id: subColumn

            anchors.horizontalCenter: parent.horizontalCenter

            spacing: config.panelPaddingLarge

            IconImage {
                id: subIcon

                anchors.horizontalCenter: parent.horizontalCenter

                implicitSize: config.iconSize

                source: root.icon
            }

            Item {
                implicitWidth:  subText.width
                implicitHeight: subText.height

                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    id: subText

                    width: config.iconSize

                    color: config.foreground

                    font.family:    config.fontFamily
                    font.pointSize: config.fontSize

                    anchors.centerIn: parent

                    transform: Rotation {
                        angle: 90

                        origin.x: subText.width  / 2
                        origin.y: subText.height / 2
                    }

                    text: root.text
                }

                TextMetrics {
                    font.family:    config.fontFamily
                    font.pointSize: config.fontSize

                    elide:      Qt.ElideRight
                    elideWidth: root.height - subIcon.height - config.panelPadding

                    onTextChanged: {
                        root.text = elidedText;
                        root.icon = helper.getIcon(helper.activeToplevel?.lastIpcObject.class ?? "");
                    }

                    text: helper.activeToplevel?.title ?? qsTr("Desktop")
                }
            }
        }
    }

    component PanelWorkspace: Item {
        id: root

        implicitWidth:  config.iconSizeLarge
        implicitHeight: config.iconSizeLarge

        required property int  index
        required property var  occupation

        readonly property bool focused:  helper.workspaceId === (index + 1)
        readonly property bool occupied: occupation[index + 1] ?? false

        Rectangle {
            anchors.fill: parent

            radius: width / 2

            color: root.focused ?
                       config.backgroundLight :
                      "transparent"

            MouseArea {
                anchors.fill: parent

                acceptedButtons: Qt.LeftButton

                onClicked: {
                    helper.dispatch(`vdesk ${index + 1}`)
                }
            }
        }

        Text {
            anchors.centerIn: parent

            font.family:    config.fontFamily
            font.pointSize: config.fontSize

            color: root.occupied ?
                       config.foreground :
                       config.foregroundDarker

            text:  root.index + 1
        }
    }

    component PanelWorkspaces: Item {
        id: root

        implicitWidth:  config.panelWidth
        implicitHeight: subColumn.height

        readonly property var occupation: {
            helper.workspaces.values.reduce((a, c) => {
                a[c.id] = c.lastIpcObject.windows > 0;
                return a;
            }, {})
        }

        Column {
            id: subColumn

            anchors.horizontalCenter: parent.horizontalCenter

            Repeater {
                model: config.panelWorkspace

                PanelWorkspace {
                    occupation: root.occupation

                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    component PanelTrayMenuEntry: Rectangle {
        id: root

        implicitWidth:  config.menuWidth - config.menuPadding * 2
        implicitHeight: modelData.isSeparator ? 1 : subText.height

        color: config.background

        required property int index
        required property var modelData

        required property var loader

        Text {
            id: subText

            anchors.left:           parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins:        config.panelPadding

            visible: !root.modelData.isSeparator

            font.family:    config.fontFamily
            font.pointSize: config.fontSize

            color: root.modelData.enabled ?
                       config.foreground :
                       config.foregroundDarker

            text:  root.modelData.text
        }

        MouseArea {
            anchors.fill: parent

            visible: root.modelData.enabled &&
                    !root.modelData.isSeparator

            hoverEnabled: true

            onEntered: {
                root.color = config.backgroundLight;
            }
            onExited: {
                root.color = config.background;
            }
            onClicked: {
                root.modelData.triggered();

                root.loader.sourceComponent = null;
            }
        }
    }

    component PanelTrayMenu: CustomWindow {
        id: root

        implicitWidth:  config.menuWidth
        implicitHeight: subColumn.height + config.panelPadding * 2

        color: config.background

        required property int index
        required property var modelData

        required property var loader

        anchors {
            left: true
            bottom: true
        }

        Column {
            id: subColumn

            anchors.centerIn: parent

            spacing: 2

            QsMenuOpener {
                id: subOpener

                menu: root.modelData
            }

            Repeater {
                model: subOpener.children

                PanelTrayMenuEntry {
                    loader: root.loader
                }
            }
        }
    }

    component PanelTrayItem: Item {
        id: root

        implicitWidth:  config.iconSize
        implicitHeight: config.iconSize

        required property int index
        required property var modelData

        IconImage {
            anchors.centerIn: parent

            implicitSize: config.iconSize

            source: root.modelData.icon

            MouseArea {
                anchors.fill: parent

                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onClicked: event => {
                    if (event.button === Qt.LeftButton)
                        root.modelData.activate();

                    else if (root.modelData.menu)
                        subLoader.sourceComponent = subComp
                }
            }
        }

        Loader {
            id: subLoader
        }

        Component {
            id: subComp

            PanelTrayMenu {
                index:     root.index
                modelData: root.modelData.menu

                loader:    subLoader
            }
        }
    }

    component PanelTray: Item {
        id: root

        implicitWidth:  config.panelWidth
        implicitHeight: subColumn.height

        visible: subColumn.children.length > 0

        Column {
            id: subColumn

            anchors.horizontalCenter: parent.horizontalCenter

            spacing: config.panelPaddingLarge

            Repeater {
                model: ScriptModel {
                    values: [...SystemTray.items.values]
                }

                PanelTrayItem {
                }
            }
        }
    }

    component PanelCalendar: Item {
        id: root

        implicitWidth:  config.panelWidth
        implicitHeight: subText.height

        Text {
            id: subText

            anchors.centerIn: parent

            color: config.foreground

            font.family:    config.fontFamily
            font.pointSize: config.fontSize

            text: helper.fmtDate("hh:mm")
        }
    }

    /*
    // Area Picker Implementation
    property bool areaPickerActive: false
    property bool areaPickerFreeze: false

    Variants {
        model: root.areaPickerActive ? Quickshell.screens : []

        PanelWindow {
            required property var modelData

            id: areaPickerWindow
            screen: modelData

            visible: root.areaPickerActive
            color: "transparent"

            implicitWidth: screen.width
            implicitHeight: screen.height

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            PanelAreaPicker {
                anchors.fill: parent
                screen: areaPickerWindow.modelData
                freeze: root.areaPickerFreeze
                onClosed: root.areaPickerActive = false
            }
        }
    }

    component PanelAreaPicker: MouseArea {
        id: picker

        required property var screen
        required property bool freeze
        signal closed()

        focus: true
        hoverEnabled: true
        cursorShape: Qt.CrossCursor

        property real startX: 0
        property real startY: 0
        property real currentX: 0
        property real currentY: 0

        property real selectionX: Math.min(startX, currentX)
        property real selectionY: Math.min(startY, currentY)
        property real selectionWidth: Math.abs(currentX - startX)
        property real selectionHeight: Math.abs(currentY - startY)

        property bool onWindow: false

        Keys.onEscapePressed: closed()

        Component.onCompleted: {
            // Initialize selection to center of screen
            startX = screen.width / 2 - 100;
            startY = screen.height / 2 - 100;
            currentX = screen.width / 2 + 100;
            currentY = screen.height / 2 + 100;
        }

        onPressed: event => {
            startX = event.x;
            startY = event.y;
            currentX = event.x;
            currentY = event.y;
        }

        onPositionChanged: event => {
            if (pressed) {
                onWindow = false;
                currentX = event.x;
                currentY = event.y;
            } else {
                // Check if over a window
                checkWindowAt(event.x, event.y);
            }
        }

        onReleased: {
            // Take screenshot of selected area
            const x = screen.x + Math.ceil(selectionX);
            const y = screen.y + Math.ceil(selectionY);
            const w = Math.floor(selectionWidth);
            const h = Math.floor(selectionHeight);

            console.log("Taking screenshot:", `${x},${y} ${w}x${h}`);
            Quickshell.execDetached(["grim", "-g", `${x},${y} ${w}x${h}`]);

            closed();
        }

        function checkWindowAt(x: real, y: real): void {
            const windows = helper.toplevels.values.filter(w => w.workspace.id === helper.workspaceId);

            for (const window of windows) {
                const obj = window.lastIpcObject;
                const wx = obj.at[0];
                const wy = obj.at[1];
                const ww = obj.size[0];
                const wh = obj.size[1];

                if (wx <= x && wy <= y && wx + ww >= x && wy + wh >= y) {
                    onWindow = true;
                    startX = wx;
                    startY = wy;
                    currentX = wx + ww;
                    currentY = wy + wh;
                    break;
                }
            }
        }

        // Semi-transparent overlay
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.3)

            // Cut out the selection area
            Rectangle {
                x: picker.selectionX
                y: picker.selectionY
                width: picker.selectionWidth
                height: picker.selectionHeight
                color: "transparent"

                // Selection border
                border.color: picker.onWindow ? config.foreground : config.backgroundLight
                border.width: 2
                radius: 4
            }
        }
    }
    */

    component Panel: CustomWindow {
        WlrLayershell.exclusionMode: ExclusionMode.Auto
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        implicitWidth: subColumn.implicitWidth

        color: config.background

        anchors {
            left:   true
            top:    true
            bottom: true
        }

        ColumnLayout {
            id: subColumn

            anchors.fill: parent

            spacing: config.panelPaddingLarge

            PanelFocus {
                // expandable
                Layout.fillHeight:   true

                Layout.alignment:    Qt.AlignHCenter
                Layout.topMargin:    config.panelPaddingLarge
            }

            PanelWorkspaces {
                Layout.alignment:    Qt.AlignHCenter
            }

            PanelTray {
                Layout.alignment:    Qt.AlignHCenter
            }

            PanelCalendar {
                Layout.alignment:    Qt.AlignHCenter
                Layout.bottomMargin: config.panelPadding
            }
        }
    }

    component Wallpaper: CustomWindow {
        id: root

        name: "wallpaper"

        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer:         WlrLayer.Background

        property string source: getRand()

        function getRand() {
            return subModel.get(Math.floor(Math.random() * subModel.count),
                               "fileURL");
        }

        FolderListModel {
            id: subModel

            folder:       "file:///home/gosh/.wall"
            nameFilters: ["*.jpg", "*.jpeg", "*.png"]
        }

        Timer {
            interval: 30 * 60 * 1000

            running: true
            repeat:  true

            onTriggered: {
                root.source = root.getRand();
            }
        }

        anchors {
            left:   true
            right:  true
            top:    true
            bottom: true
        }

        Image {
            anchors.fill: parent

            opacity: 1
            scale:   1

            source: root.source
        }
    }

    component LauncherItem: Item {
        id: root

        implicitWidth:  config.launcherWidth - config.launcherPadding * 2
        implicitHeight: config.launcherHeightApp

        required property var modelData

        required property var loader

        Rectangle {
            id: subRec

            anchors.fill: parent

            color: config.background

            RowLayout {
                anchors.fill: parent

                spacing: config.launcherPadding

                IconImage {
                    Layout.alignment: Qt.AlignVCenter

                    implicitSize: config.iconSizeHuge

                    source: helper.getIcon(root.modelData?.icon, "image-missing")
                }

                Column {
                    id: subColumn

                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillWidth: true

                    Text {
                        font.family:    config.fontFamily
                        font.pointSize: config.fontSizeLarge

                        color: config.foreground

                        text: root.modelData?.name ?? ""
                    }

                    Text {
                        font.family:    config.fontFamily
                        font.pointSize: config.fontSize

                        color: config.foregroundDarker

                        TextMetrics {
                            id: subMetrics

                            elide:      Qt.ElideRight
                            elideWidth: subColumn.width

                            text: (root.modelData?.comment || root.modelData?.name) ?? ""
                        }

                        text: subMetrics.elidedText
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent

            hoverEnabled: true

            onEntered: {
                subRec.color = config.backgroundLight;
            }
            onExited: {
                subRec.color = config.background;
            }
            onClicked: {
                helper.launch(root.modelData)

                root.loader.sourceComponent = null;
            }
        }
    }

    component LauncherList: ListView {
        id: root

        width:  config.launcherWidth - config.launcherPadding * 2
        height: config.launcherHeightApp * config.launcherApp

        model: ScriptModel {
            values: root.getApps()

            onValuesChanged: {
                root.currentIndex = 0;
            }
        }

        spacing:     0
        orientation: Qt.Vertical

        delegate: {
            return subComp;
        }

        required property string name
        required property var    loader

        function getApps() {
            return helper.getApp(name)
        }

        Component {
            id: subComp

            LauncherItem {
                loader: root.loader
            }
        }
    }

    component Launcher: CustomWindow {
        id: root

        implicitWidth:  config.launcherWidth
        implicitHeight: config.launcherHeightApp * config.launcherApp +
                        config.launcherHeightInp

        color: config.background

        required property var loader

        Column {
            anchors.fill: parent

            spacing: 0

            RowLayout {
                implicitWidth:  parent.implicitWidth
                implicitHeight: config.launcherHeightInp

                IconImage {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 20

                    implicitSize: config.iconSizeLarge

                    source: helper.getIcon("search")
                }

                TextField {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillWidth: true

                    id: subField

                    implicitHeight: config.iconSizeLarge - config.launcherPadding * 2

                    color: config.backgroundLight

                    onAccepted: {
                        const curr = subList.currentList?.currentItem;

                        if (curr) {
                            helper.launch(curr.modelData);

                            root.loader.sourceComponent = null;
                        }
                    }

                    Keys.onUpPressed: {
                        subList.currentList?.decrementCurrentIndex()
                    }
                    Keys.onDownPressed: {
                        subList.currentList?.incrementCurrentIndex()
                    }
                    Keys.onEscapePressed: {
                        root.loader.sourceComponent = null;
                    }
                }

                IconImage {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: 20

                    implicitSize: config.iconSizeLarge

                    source: helper.getIcon("close")

                    MouseArea {
                        onClicked: {
                            subField.text = "";
                        }
                    }
                }
            }

            LauncherList {
                id: subList

                implicitWidth:  parent.width
                implicitHeight: config.launcherHeightApp * config.launcherApp

                name:   subField.text
                loader: root.loader
            }
        }
    }

    component LauncherWrapper: Item {
        id: root

        function launch(): void {
            subLoader.sourceComponent = subComp
        }

        Loader {
            id: subLoader
        }

        Component {
            id: subComp

            Launcher {
                loader: subLoader
            }
        }
    }

    Variants {
        model: Quickshell.screens

        Scope {
            id: subScope

            property var modelData

            Panel {
                screen: subScope.modelData
            }

            Wallpaper {
                screen: subScope.modelData
            }
        }
    }

    LauncherWrapper {
        id: launcher
    }

    CustomShortcut {
        name:        "launcher"
        description: "Launch launcher"

        onPressed: {
            launcher.launch()
        }
    }
}
