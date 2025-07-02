import Qt.labs.folderlistmodel

import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Services.Pam
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
        readonly property color  foreground:         "#abb2bf"
        readonly property color  foregroundDark:     "#848b98"
        readonly property color  foregroundDarker:   "#5f6571"
        readonly property color  background:         "#23272e"
        readonly property color  backgroundLight:    "#31353f"

        readonly property color  backgroundRed:      "#993939"
        readonly property color  backgroundYellow:   "#93691d"
        readonly property color  backgroundPurple:   "#8a3fa0"

        readonly property string fontFamily:         "Cantarell"
        readonly property int    fontSize:            10
        readonly property int    fontSizeLarge:       12
        readonly property int    fontSizeHuge:        64

        readonly property int    panelWidth:          48
        readonly property int    panelPadding:        4
        readonly property int    panelPaddingLarge:   12
        readonly property int    panelWorkspaceShown: 5

        readonly property int    iconSize:            20
        readonly property int    iconSizeLarge:       28
        readonly property int    iconSizeHuge:        42

        readonly property int    menuEntryWidth:      320
        readonly property int    menuEntryHeight:     20
        readonly property int    menuPadding:         4

        readonly property int    launcherWidth:       640
        readonly property int    launcherHeight:      48
        readonly property int    launcherPadding:     4
        readonly property int    launcherItemShown:   8

        readonly property int    lockerWidth:         320
        readonly property int    lockerHeight:        32
        readonly property int    lockerPadding:       8

        readonly property int    notifierWidth:       480
        readonly property int    notifierHeight:      48
        readonly property int    notifierPadding:     4
        readonly property int    notifierItemShown:   8
    }

    component GlobalHelper: Item {
        id: root

        // icon
        function getIcon(desc) {
            const trial = Quickshell.iconPath(desc, true);

            if (trial.length > 0)
                return trial;

            return Quickshell.iconPath("image-missing", true);
        }

        // apps
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

        // time
        SystemClock {
            id: subclock

            precision: SystemClock.Seconds
        }

        function fmtDate(fmt: string): string {
            return Qt.formatDateTime(subclock.date, fmt);
        }

        // notif
        readonly property list<var> notifs: []

        NotificationServer {
            id: subnotif

            keepOnReload: false

            actionsSupported:        true
            bodyHyperlinksSupported: true
            bodyImagesSupported:     true
            bodyMarkupSupported:     true
            imageSupported:          true

            onNotification: notif => {
                notif.tracked = true;

                root.notifs.push(notif);
            }
        }

        // hypr
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

        implicitWidth:  widget.implicitWidth
        implicitHeight: widget.implicitHeight

        property string icon: helper.getIcon("")

        Column {
            id: widget

            spacing: config.panelPaddingLarge

            IconImage {
                implicitSize: config.iconSize

                source: root.icon
            }

            Text {
                id: subtext

                width: config.iconSize

                font.family:    config.fontFamily
                font.pointSize: config.fontSize

                color: config.foreground

                transform: Rotation {
                    angle: 90

                    origin.x: subtext.width  / 2
                    origin.y: subtext.height / 2
                }

                text: submetrics.text

                TextMetrics {
                    id: submetrics

                    font.family:    config.fontFamily
                    font.pointSize: config.fontSize

                    elide:      Qt.ElideRight
                    elideWidth: parent.height

                    onTextChanged: {
                        root.icon = helper.getIcon(helper.activeToplevel?.lastIpcObject.class ?? "");
                    }

                    text: helper.activeToplevel?.title ?? qsTr("Desktop")
                }
            }
        }
    }

    component PanelWorkspace: Item {
        id: root

        implicitWidth:  widget.implicitWidth
        implicitHeight: widget.implicitHeight

        required property int  index
        required property var  occupation

        readonly property bool focused:  helper.workspaceId === (index + 1)
        readonly property bool occupied: occupation[index + 1] ?? false

        Rectangle {
            id: widget

            implicitWidth:  config.iconSizeLarge
            implicitHeight: config.iconSizeLarge

            radius: width / 2

            color:  root.focused ?
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

        implicitWidth:  widget.implicitWidth
        implicitHeight: widget.implicitHeight

        readonly property var occupation: {
            helper.workspaces.values.reduce((a, c) => {
                a[c.id] = c.lastIpcObject.windows > 0;
                return a;
            }, {})
        }

        Column {
            id: widget

            Repeater {
                model: config.panelWorkspaceShown

                PanelWorkspace {
                    occupation: root.occupation
                }
            }
        }
    }

    component PanelTrayMenuEntry: Rectangle {
        id: root

        implicitWidth:  widget.implicitWidth
        implicitHeight: widget.implicitHeight

        color: config.background

        required property int index
        required property var modelData
        required property var loader

        Rectangle {
            id: widget

            implicitWidth:  config.menuEntryWidth
            implicitHeight: root.modelData.isSeparator ? 1 : config.menuEntryHeight

            color: config.background

            Text {
                id: subtext

                anchors.verticalCenter: parent.verticalCenter
                anchors.margins:        config.menuPadding

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
                    widget.color = config.backgroundLight;
                }
                onExited: {
                    widget.color = config.background;
                }
                onClicked: {
                    root.modelData.triggered();

                    root.loader.sourceComponent = null;
                }
            }
        }
    }

    component PanelTrayMenu: CustomWindow {
        id: root

        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        anchors.left:   true
        anchors.bottom: true

        implicitWidth:  widget.implicitWidth  + config.menuPadding * 2
        implicitHeight: widget.implicitHeight + config.menuPadding * 2

        color: config.background

        required property int index
        required property var modelData
        required property var loader

        Column {
            id: widget

            anchors.centerIn: parent

            focus: true

            spacing: config.menuPadding

            QsMenuOpener {
                id: subopener

                menu: root.modelData
            }

            Repeater {
                model: subopener.children

                PanelTrayMenuEntry {
                    loader: root.loader
                }
            }

            Keys.onEscapePressed: {
                root.loader.sourceComponent = null;
            }
        }
    }

    component PanelTrayItem: Item {
        id: root

        implicitWidth:  widget.implicitWidth
        implicitHeight: widget.implicitHeight

        required property int index
        required property var modelData

        IconImage {
            id: widget

            implicitSize: config.iconSize

            source: root.modelData.icon

            MouseArea {
                anchors.fill: parent

                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onClicked: event => {
                    if (event.button === Qt.LeftButton)
                        root.modelData.activate();

                    else if (root.modelData.menu)
                        subloader.sourceComponent = subcomp
                }
            }
        }

        Loader {
            id: subloader
        }

        Component {
            id: subcomp

            PanelTrayMenu {
                index:     root.index
                modelData: root.modelData.menu

                loader:    subloader
            }
        }
    }

    component PanelTray: Item {
        id: root

        visible: widget.children.length > 0

        implicitWidth:  widget.implicitWidth
        implicitHeight: widget.implicitHeight

        Column {
            id: widget

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

        implicitWidth:  widget.implicitWidth
        implicitHeight: widget.implicitHeight

        Text {
            id: widget

            font.family:    config.fontFamily
            font.pointSize: config.fontSize

            color: config.foreground

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

        anchors.left:   true
        anchors.top:    true
        anchors.bottom: true

        implicitWidth: config.panelWidth

        color: config.background

        ColumnLayout {
            anchors.top:              parent.top
            anchors.bottom:           parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            spacing: config.panelPaddingLarge

            PanelFocus {
                Layout.alignment:    Qt.AlignHCenter
                Layout.topMargin:    config.panelPadding

                Layout.fillHeight:   true
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

        implicitWidth:  widget.implicitWidth
        implicitHeight: widget.implicitHeight

        required property int index
        required property var modelData

        required property var list
        required property var loader

        Rectangle {
            id: widget

            implicitWidth:  config.launcherWidth
            implicitHeight: config.launcherHeight

            color: "transparent"

            RowLayout {
                anchors.verticalCenter: parent.verticalCenter

                IconImage {
                    Layout.alignment:   Qt.AlignVCenter
                    Layout.leftMargin:  config.launcherPadding

                    implicitSize: config.iconSizeHuge

                    source: helper.getIcon(root.modelData?.icon)
                }

                Column {
                    Layout.alignment:   Qt.AlignVCenter
                    Layout.rightMargin: config.launcherPadding

                    Layout.fillWidth:   true

                    id: subcol

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
                            id: submetrics

                            font.family:    config.fontFamily
                            font.pointSize: config.fontSize

                            elide:      Qt.ElideRight
                            elideWidth: subcol.width

                            text: (root.modelData?.comment || root.modelData?.name) ?? ""
                        }

                        text: submetrics.elidedText
                    }
                }
            }

            MouseArea {
                anchors.fill: parent

                hoverEnabled: true

                onEntered: {
                    root.list.currentIndex = index;
                }
                onClicked: {
                    helper.launch(root.modelData)

                    root.loader.sourceComponent = null;
                }
            }
        }
    }

    component LauncherList: Item {
        id: root

        implicitWidth:  widget.implicitWidth
        implicitHeight: widget.implicitHeight

        required property var name
        required property var loader

        function incr(): void {
            widget.incrementCurrentIndex();
        }
        function decr(): void {
            widget.decrementCurrentIndex();
        }
        function curr(): var {
            return widget.currentItem;
        }

        ListView {
            id: widget

            implicitWidth:  config.launcherWidth
            implicitHeight: config.launcherHeight * config.launcherItemShown

            clip:  true
            focus: true

            spacing:     config.launcherPadding
            orientation: Qt.Vertical

            model: ScriptModel {
                values: helper.getApp(name)

                onValuesChanged: {
                    widget.currentIndex = 0;
                }
            }

            currentIndex: 0

            highlight: Rectangle {
                color: config.backgroundLight
            }

            highlightMoveDuration:    0
            highlightMoveVelocity:   -1
            highlightResizeDuration:  0
            highlightResizeVelocity: -1

            delegate: subcomp

            Component {
                id: subcomp

                LauncherItem {
                    list:   widget
                    loader: root.loader
                }
            }
        }
    }

    component Launcher: CustomWindow {
        id: root

        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        implicitWidth:  widget.implicitWidth
        implicitHeight: widget.implicitHeight

        color: config.background

        required property var loader

        Column {
            id: widget

            Item {
                implicitWidth:  config.launcherWidth
                implicitHeight: config.launcherHeight

                TextField {
                    id: subtext

                    anchors.centerIn: parent

                    implicitWidth:  config.launcherWidth     / 2
                    implicitHeight: config.launcherHeightApp / 1.6

                    focus: true

                    font.family:    config.fontFamily
                    font.pointSize: config.fontSizeLarge

                    color: config.foreground

                    leftPadding:  height / 2
                    rightPadding: height / 2

                    cursorDelegate: Item {
                    }

                    background: Rectangle {
                        anchors.fill: parent

                        radius: height / 2

                        color:  config.backgroundLight
                    }

                    onAccepted: {
                        const curr = sublist.curr();

                        if (curr)
                            helper.launch(curr.modelData);

                        root.loader.sourceComponent = null;
                    }
                }
            }

            LauncherList {
                id: sublist

                name:   subtext.text
                loader: root.loader
            }

            Keys.onUpPressed: {
                sublist.decr();
            }
            Keys.onDownPressed: {
                sublist.incr();
            }
            Keys.onEscapePressed: {
                root.loader.sourceComponent = null;
            }
        }
    }

    component LauncherWrapper: Item {
        id: root

        function launch(): void {
            subloader.sourceComponent = subcomp
        }

        Loader {
            id: subloader
        }

        Component {
            id: subcomp

            Launcher {
                loader: subloader
            }
        }
    }

    Variants {
        model: Quickshell.screens

        Scope {
            id: subscope

            property var modelData

            Panel {
                screen: subscope.modelData
            }

            Wallpaper {
                screen: subscope.modelData
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

    component Locker: WlSessionLockSurface {
        id: root

        required property var lock

        property color color: config.backgroundLight

        ScreencopyView {
            id: subscreen

            anchors.fill: parent

            visible: true

            captureSource: root.screen
        }

        MultiEffect {
            id: subeffect

            anchors.fill: parent

            source: subscreen

            autoPaddingEnabled: false

            blurEnabled:    true
            blur:           1
            blurMax:        64
            blurMultiplier: 2
        }

        PamContext {
            id: subpam

            onResponseRequiredChanged: {
                if (!responseRequired)
                    return;

                respond(widget.text)
            }

            onCompleted: res => {
                if (res === PamResult.Success) {
                    root.lock.locked = false;
                    return;
                }

                widget.text = "";

                if (res === PamResult.Error)
                    root.color = config.backgroundYellow
                else if (res === PamResult.MaxTries)
                    root.color = config.backgroundPurple
                else if (res === PamResult.Failed)
                    root.color = config.backgroundRed
            }
        }

        Column {
            anchors.centerIn: parent

            spacing: config.lockerPadding

            Text {
                anchors.horizontalCenter: parent.horizontalCenter

                font.family:    config.fontFamily
                font.pointSize: config.fontSizeHuge

                color: config.foreground

                style:     "Raised"
                styleColor: config.background

                text: helper.fmtDate("hh:mm")
            }

            TextField {
                id: widget

                anchors.horizontalCenter: parent.horizontalCenter

                implicitWidth:  config.lockerWidth
                implicitHeight: config.lockerHeight

                focus: true

                font.family:    config.fontFamily
                font.pointSize: config.fontSizeLarge

                color: config.foreground

                leftPadding:  height / 2
                rightPadding: height / 2

                echoMode:          TextInput.Password
                passwordMaskDelay: 0

                cursorDelegate: Item {
                }

                background: Rectangle {
                    anchors.fill: parent

                    radius: height / 2

                    color:  root.color
                }

                onTextChanged: {
                    root.color = config.backgroundLight
                }

                onAccepted: {
                    if (subpam.active)
                        return;

                    subpam.start();
                }
            }
        }
    }

    component LockerWrapper: Item {
        id: root

        function launch(): void {
            subloader.sourceComponent = subcomp
        }

        Loader {
            id: subloader
        }

        Component {
            id: subcomp

            WlSessionLock {
                id: sublock

                locked: true

                onLockedChanged: {
                    if (!locked)
                        subloader.sourceComponent = null;
                }

                Locker {
                    lock: sublock
                }
            }
        }
    }

    LockerWrapper {
        id: locker
    }

    CustomShortcut {
        name:        "lock"
        description: "Launch locker"

        onPressed: {
            locker.launch()
        }
    }

    component NotifierItem: Item {
        id: root

        implicitWidth:  widget.implicitWidth
        implicitHeight: widget.implicitHeight

        required property int index
        required property var modelData

        required property var list
        required property var loader

        Rectangle {
            id: widget

            implicitWidth:  config.launcherWidth
            implicitHeight: config.launcherHeight

            color: "transparent"

            RowLayout {
                anchors.verticalCenter: parent.verticalCenter

                IconImage {
                    Layout.alignment:   Qt.AlignVCenter
                    Layout.leftMargin:  config.launcherPadding

                    visible: root.modelData.appIcon.length > 0

                    implicitSize: config.iconSizeHuge

                    source: helper.getIcon(root.modelData.appIcon)
                }

                Column {
                    Layout.alignment:   Qt.AlignVCenter
                    Layout.rightMargin: config.launcherPadding

                    Layout.fillWidth:   true

                    id: subcol

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
                            id: submetrics

                            font.family:    config.fontFamily
                            font.pointSize: config.fontSize

                            elide:      Qt.ElideRight
                            elideWidth: subcol.width

                            text: (root.modelData?.comment || root.modelData?.name) ?? ""
                        }

                        text: submetrics.elidedText
                    }
                }
            }

            MouseArea {
                anchors.fill: parent

                hoverEnabled: true

                onEntered: {
                    root.list.currentIndex = index;
                }
                onClicked: {
                    helper.launch(root.modelData)

                    root.loader.sourceComponent = null;
                }
            }
        }
    }

    component Notifier: CustomWindow {
        id: root

        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        anchors.right:  true
        anchors.bottom: true

        implicitWidth:  widget.implicitWidth
        implicitHeight: widget.implicitHeight

        color: config.background

        required property var loader

        ListView {
            id: widget

            implicitWidth:  config.notifierWidth
            implicitHeight: config.notifierHeight * Math.max(config.notifierShown, helper.notifs.length)

            clip:  true
            focus: true

            spacing:     config.notifierPadding
            orientation: Qt.Vertical

            model: ScriptModel {
                values: helper.notifs

                onValuesChanged: {
                    widget.currentIndex = 0;
                }
            }

            currentIndex: 0

            highlight: Rectangle {
                color: config.backgroundLight
            }

            highlightMoveDuration:    0
            highlightMoveVelocity:   -1
            highlightResizeDuration:  0
            highlightResizeVelocity: -1

            delegate: subcomp

            Component {
                id: subcomp

                NotifierItem {
                    list:   widget
                    loader: root.loader
                }
            }
        }
    }

    component NotifierWrapper: Item {
        id: root

        function launch(): void {
            if (subloader.sourceComponent === null)
                subloader.sourceComponent = subcomp
        }

        Loader {
            id: subloader
        }

        Component {
            id: subcomp

            Variants {
                model: Quickshell.screens

                Scope {
                    id: subscope

                    property var modelData

                    Notifier {
                        screen: subscope.modelData
                        loader: subloader
                    }
                }
            }
        }
    }

    NotifierWrapper {
        id: notifier
    }
}
