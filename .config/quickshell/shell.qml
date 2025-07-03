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
import Quickshell.Services.Pipewire
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

    component CustomText: Text {
        font.family:    config.fontFamily
        font.pointSize: config.fontSize

        color: config.foreground
    }

    component CustomTextMetrics: TextMetrics {
        font.family:    config.fontFamily
        font.pointSize: config.fontSize

        elide:      Qt.ElideRight
        elideWidth: parent.width
    }

    component CustomListView: ListView {
        clip:  true
        focus: true

        orientation: Qt.Vertical

        currentIndex: 0

        highlight: Rectangle {
            color: config.backgroundLight
        }

        highlightMoveDuration:    0
        highlightMoveVelocity:   -1
        highlightResizeDuration:  0
        highlightResizeVelocity: -1
    }

    component CustomPopout: Item {
        required property var comp

        property var loader: subloader

        function exec(): void {
            subloader.active = true;
        }
        function done(): void {
            subloader.active = false;
        }

        Loader {
            id: subloader

            active: false

            sourceComponent: comp
        }
    }

    component GlobalConfig: Item {
        id: root

        readonly property color  foreground:         "#abb2bf"
        readonly property color  foregroundDark:     "#848b98"
        readonly property color  foregroundDarker:   "#5f6571"
        readonly property color  backgroundLight:    "#31353f"
        readonly property color  background:         "#23272e"

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
        readonly property int    menuEntryHeight:     28
        readonly property int    menuSLineHeight:     2
        readonly property int    menuPadding:         4

        readonly property int    launcherWidth:       640
        readonly property int    launcherHeight:      48
        readonly property int    launcherPadding:     8
        readonly property int    launcherItemShown:   5

        readonly property int    lockerWidth:         320
        readonly property int    lockerHeight:        32
        readonly property int    lockerPadding:       8

        readonly property int    notifierWidth:       320
        readonly property int    notifierHeight:      48
        readonly property int    notifierPadding:     4
        readonly property int    notifierItemShown:   5

        readonly property real   pickerOpacity:       0.75

        property int clientRounding: 0

        Process {
            running:   true
            command: ["hyprctl", "-j", "getoption", "decoration:rounding"]

            stdout: StdioCollector {
                onStreamFinished: root.clientRounding = JSON.parse(text).int
            }
        }
    }

    component GlobalHelper: Item {
        id: root

        // icon
        function getIcon(str: string): string {
            const trial = Quickshell.iconPath(str, true);

            if (trial.length > 0)
                return trial;

            return Quickshell.iconPath("image-missing", true);
        }
        function getIconSum(str: string): string {
            if (str.includes("welcome"))
                return "waving_hand";
            if (str.includes("recording"))
                return "screen_record";
            if (str.includes("screenshot"))
                return "screenshot_monitor";
            if (str.includes("time"))
                return "schedule";
            if (str.includes("installed"))
                return "download";
            if (str.includes("update"))
                return "update";
            if (str.includes("unable to"))
                return "deployed_code_alert";
            if (str.includes("reboot"))
                return "restart_alt";
            if (str.includes("file"))
                return "folder_copy";
            if (str.includes("profile"))
                return "person";

            return "";
        }

        // apps
        readonly property var  rawApplications: {
            DesktopEntries.applications.values.filter(
                a => !a.noDisplay
            ).sort((a, b) =>
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
        readonly property var notifs: subnotif.trackedNotifications

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

                notifier.exec();
            }
        }

        // audio
        readonly property var audioSink: Pipewire.defaultAudioSink

        function incVolume(vol: real): real {
            if (audioSink?.ready && audioSink?.audio) {
                audioSink.audio.muted  = false;
                audioSink.audio.volume = audioSink.audio.volume + vol;

                return audioSink.audio.volume;
            }

            return -1;
        }
        function decVolume(vol: real): real {
            if (audioSink?.ready && audioSink?.audio) {
                audioSink.audio.muted  = false;
                audioSink.audio.volume = audioSink.audio.volume - vol;

                return audioSink.audio.volume;
            }

            return -1;
        }
        function mute(): void {
            if (audioSink?.ready && audioSink?.audio)
                audioSink.audio.muted  = true;
        }

        PwObjectTracker {
            objects: [Pipewire.defaultAudioSink]
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
    }

    GlobalConfig {
        id: config
    }

    GlobalHelper {
        id: helper
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

            CustomText {
                id: subtext

                width: config.iconSize

                transform: Rotation {
                    angle: 90

                    origin.x: subtext.width  / 2
                    origin.y: subtext.height / 2
                }

                text: submetrics.text
            }

            CustomTextMetrics {
                id: submetrics

                onTextChanged: {
                    root.icon = helper.getIcon(
                        helper.activeToplevel?.lastIpcObject.class ?? "");
                }

                text: helper.activeToplevel?.title ?? qsTr("Desktop")
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

        CustomText {
            anchors.centerIn: parent

            color: root.occupied ?
                       config.foreground :
                       config.foregroundDarker

            text: root.index + 1
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

    component PanelTrayMenuItem: Item {
        id: root

        implicitWidth:  widget.implicitWidth
        implicitHeight: widget.implicitHeight

        required property int index
        required property var modelData
        required property var popout

        Rectangle {
            id: widget

            implicitWidth:  config.menuEntryWidth
            implicitHeight: root.modelData.isSeparator ?
                                config.menuSLineHeight :
                                config.menuEntryHeight

            color: config.background

            CustomText {
                id: subtext

                anchors.verticalCenter: parent.verticalCenter

                anchors.left:       parent.left
                anchors.leftMargin: config.menuPadding

                visible: !root.modelData.isSeparator

                font.pointSize: config.fontSizeLarge

                color: root.modelData.enabled ?
                           config.foreground :
                           config.foregroundDarker

                text: submetrics.elidedText
            }

            CustomTextMetrics {
                id: submetrics

                font.pointSize: config.fontSizeLarge

                elide:      Qt.ElideRight
                elideWidth: parent.width - config.menuPadding * 2

                text: root.modelData.text
            }
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

                root.popout.done();
            }
        }
    }

    component PanelTrayMenu: CustomWindow {
        id: root

        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        anchors.left:   true
        anchors.bottom: true

        implicitWidth:  widget.implicitWidth
        implicitHeight: widget.implicitHeight

        color: config.background

        required property var modelData
        required property var popout

        Column {
            id: widget

            focus: true

            QsMenuOpener {
                id: subopener

                menu: root.modelData
            }

            Repeater {
                model: subopener.children

                PanelTrayMenuItem {
                    popout: root.popout
                }
            }

            Keys.onEscapePressed: {
                root.popout.done();
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
        }

        CustomPopout {
            id: subpop

            comp: Component {
                PanelTrayMenu {
                    modelData: root.modelData.menu
                    popout:    subpop
                }
            }
        }

        MouseArea {
            anchors.fill: parent

            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: event => {
                if (event.button === Qt.LeftButton)
                    root.modelData.activate();

                else if (root.modelData.menu)
                    subpop.exec();
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

        CustomText {
            id: widget

            text: helper.fmtDate("hh:mm")
        }
    }

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

        anchors.left:   true
        anchors.right:  true
        anchors.top:    true
        anchors.bottom: true

        property string source: ""

        function getRand() {
            return submodel.get(Math.floor(Math.random() % submodel.count),
                               "fileURL");
        }

        FolderListModel {
            id: submodel

            folder: "file:///home/gosh/.wall"

            showDirs:  false
            showFiles: true

            nameFilters: ["*.jpg", "*.jpeg", "*.png"]

            onStatusChanged: {
                if (status === FolderListModel.Ready)
                    subtimer.start();
            }
        }

        Timer {
            id: subtimer

            interval: 30 * 60 * 1000

            running: false
            repeat:  true

            triggeredOnStart: true

            onTriggered: {
                root.source = root.getRand();
            }
        }

        Image {
            anchors.fill: parent

            opacity: 1
            scale:   1

            source: root.source
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

    component ExecerItem: Item {
        id: root

        implicitWidth:  widget.implicitWidth
        implicitHeight: widget.implicitHeight

        required property int index
        required property var modelData
        required property var list
        required property var popout

        Rectangle {
            id: widget

            implicitWidth:  config.launcherWidth
            implicitHeight: config.launcherHeight

            color: "transparent"

            RowLayout {
                anchors.verticalCenter: parent.verticalCenter

                anchors.left:       parent.left
                anchors.leftMargin: config.launcherPadding

                spacing: config.launcherPadding

                IconImage {
                    Layout.alignment: Qt.AlignVCenter

                    implicitSize: config.iconSizeHuge

                    source: helper.getIcon(root.modelData?.icon)
                }

                Column {
                    Layout.alignment: Qt.AlignVCenter

                    Layout.fillWidth: true

                    CustomText {
                        font.pointSize: config.fontSizeLarge

                        text: root.modelData?.name ?? ""
                    }

                    CustomText {
                        color: config.foregroundDarker

                        text: submetrics.elidedText

                    }

                    TextMetrics {
                        id: submetrics

                        text: (root.modelData?.comment ||
                               root.modelData?.name) ?? ""
                    }
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

                root.popout.done();
            }
        }
    }

    component ExecerList: Item {
        id: root

        implicitWidth:  widget.implicitWidth
        implicitHeight: widget.implicitHeight

        required property var name
        required property var popout

        function incr(): void {
            widget.incrementCurrentIndex();
        }
        function decr(): void {
            widget.decrementCurrentIndex();
        }
        function curr(): var {
            return widget.currentItem;
        }

        CustomListView {
            id: widget

            implicitWidth:  config.launcherWidth
            implicitHeight: config.launcherHeight * config.launcherItemShown

            model: ScriptModel {
                values: helper.getApp(name)

                onValuesChanged: {
                    if (values.length > 0)
                        widget.currentIndex = 0;
                }
            }

            delegate: subcomp

            Component {
                id: subcomp

                ExecerItem {
                    list:   widget
                    popout: root.popout
                }
            }
        }
    }

    component Execer: CustomWindow {
        id: root

        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        implicitWidth:  widget.implicitWidth
        implicitHeight: widget.implicitHeight

        color: config.background

        required property var popout

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

                        if (curr) {
                            helper.launch(curr.modelData);
                            root.popout.done();
                        }
                    }
                }
            }

            ExecerList {
                id: sublist

                name:   subtext.text
                popout: root.popout
            }

            Keys.onUpPressed: {
                sublist.decr();
            }
            Keys.onDownPressed: {
                sublist.incr();
            }
            Keys.onEscapePressed: {
                root.popout.done();
            }
        }
    }

    CustomPopout {
        id: launcher

        comp: Component {
            Execer {
                popout: launcher
            }
        }
    }

    CustomShortcut {
        name:        "execer"
        description: "Start execer"

        onPressed: {
            launcher.exec()
        }
    }

    component LockerSurface: WlSessionLockSurface {
        id: root

        required property var locker

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

            property string reason: ""

            onResponseRequiredChanged: {
                if (!responseRequired)
                    return;

                respond(widget.text)
            }

            onCompleted: res => {
                if (res === PamResult.Success) {
                    root.locker.locked = false;
                    return;
                }

                widget.text = "";

                if (res === PamResult.Error)
                    reason = "error"
                else if (res === PamResult.MaxTries)
                    reason = "max"
                else if (res === PamResult.Failed)
                    reason = "failed"
            }
        }

        Column {
            anchors.centerIn: parent

            spacing: config.lockerPadding

            CustomText {
                anchors.horizontalCenter: parent.horizontalCenter

                font.pointSize: config.fontSizeHuge

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

                    color: {
                        if (subpam.reason === "error")
                            return config.backgroundYellow
                        else if (subpam.reason === "max")
                            return config.backgroundPurple
                        else if (subpam.reason === "failed")
                            return config.backgroundRed
                        else
                            return config.backgroundLight
                    }
                }

                onTextChanged: {
                    subpam.reason = "";
                }

                onAccepted: {
                    if (subpam.active)
                        return;

                    subpam.start();
                }
            }
        }
    }

    component Locker: WlSessionLock {
        id: root

        locked: true

        required property var popout

        onLockedChanged: {
            if (!locked)
                popout.done();
        }

        LockerSurface {
            locker: root
        }
    }

    CustomPopout {
        id: locker

        comp: Component {
            Locker {
                popout: locker
            }
        }
    }

    CustomShortcut {
        name:        "locker"
        description: "Start locker"

        onPressed: {
            locker.exec()
        }
    }

    component NotifierItem: Item {
        id: root

        implicitWidth:  widget.implicitWidth
        implicitHeight: widget.implicitHeight

        required property int index
        required property var modelData
        required property var list

        Rectangle {
            id: widget

            implicitWidth:  config.notifierWidth
            implicitHeight: config.notifierHeight

            color: {
                if (modelData.urgency === NotificationUrgency.Critical)
                    return config.backgroundRed;
                else if (modelData.urgency === NotificationUrgency.Low)
                    return config.backgroundYellow;
                else
                    return "transparent";
            }

            RowLayout {
                anchors.verticalCenter: parent.verticalCenter

                anchors.left:       parent.left
                anchors.leftMargin: config.notifierPadding

                spacing: config.notifierPadding

                Rectangle {
                    Layout.alignment:   Qt.AlignVCenter
                    Layout.leftMargin:  config.notifierPadding

                    visible: root.modelData.image.length > 0

                    implicitWidth:  config.iconSizeHuge
                    implicitHeight: config.iconSizeHuge

                    color: "transparent"

                    Image {
                        anchors.fill: parent

                        fillMode: Image.PreserveAspectCrop

                        source: Qt.resolvedUrl(root.modelData.image)
                    }
                }

                IconImage {
                    Layout.alignment:   Qt.AlignVCenter
                    Layout.leftMargin:  config.notifierPadding

                    visible: root.modelData.image.length === 0

                    implicitSize: config.iconSizeHuge

                    source: {
                        var str = root.modelData.appIcon;

                        if (str.length === 0) {
                            const sum = root.modelData.summary.toLowerCase();

                            str = helper.getIconSum(sum);
                        }

                        return helper.getIcon(str);
                    }
                }

                Column {
                    Layout.alignment:   Qt.AlignVCenter
                    Layout.rightMargin: config.notifierPadding

                    Layout.fillWidth:   true

                    id: subcol

                    CustomText {
                        font.pointSize: config.fontSizeLarge

                        text: root.modelData.summary
                    }

                    CustomText {
                        color: config.foregroundDarker

                        text: submetricsBody.elidedText
                    }

                    TextMetrics {
                        id: submetricsBody

                        text: root.modelData.body
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent

            hoverEnabled: true

            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onEntered: {
                root.list.currentIndex = index;
            }
            onClicked: e => {
                if (e.button === Qt.LeftButton)
                    for (var i = 0; i < root.modelData.actions.length; i++)
                        root.modelData.actions[i].invoke();

                root.modelData.tracked = false;
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

        required property var popout

        CustomListView {
            id: widget

            implicitWidth:  config.notifierWidth
            implicitHeight: config.notifierHeight *
                            Math.min(config.notifierItemShown,
                                     helper.notifs.values.length)

            model: ScriptModel {
                values: helper.notifs.values

                onValuesChanged: {
                    if (values.length > 0)
                        widget.currentIndex = 0;
                    else
                        root.popout.done();
                }
            }

            delegate: subcomp

            Component {
                id: subcomp

                NotifierItem {
                    list: widget
                }
            }
        }
    }

    component NotifierAll: Item {
        id: root

        required property var popout

        Variants {
            model: Quickshell.screens

            Scope {
                id: subscope

                property var modelData

                Notifier {
                    screen: subscope.modelData
                    popout: root.popout
                }
            }
        }
    }

    CustomPopout {
        id: notifier

        function exec(): void {
            if (loader.active === false)
                loader.active = true
        }

        comp: Component {
            NotifierAll {
                popout: notifier
            }
        }
    }

    component PickerArea: MouseArea {
        id: root

        anchors.fill: parent

        focus: true

        hoverEnabled: true

        required property var screen
        required property var popout

        property real preX: 0
        property real preY: 0
        property real curX: 0
        property real curY: 0

        property real selX: 0
        property real selY: 0
        property real selW: 0
        property real selH: 0

        property bool pressed: false

        property list<var> clients: {
            return helper.toplevels.values.filter(c =>
                (c.workspace?.active ?? false) &&
                (c.workspace.monitor.name === screen.name)
            ).map(c => conv(c)).sort((a, b) => a.t - b.t);
        }

        function conv(c: var): var {
            const o = c.lastIpcObject;
            const r = screen.devicePixelRatio;

            return {
                x: (o.at  [0] - screen.x) / r,
                y: (o.at  [1] - screen.y) / r,
                w:  o.size[0]             / r,
                h:  o.size[1]             / r,

                t:  o.pinned   ? 0 :
                    o.floating ? 1 :
                                 2
            };
        }
        function over(): void {
            for (const c of clients)
                if ((c.x <= curX) && (c.x + c.w >= curX) &&
                    (c.y <= curY) && (c.y + c.h >= curY)) {
                    selX = c.x;
                    selY = c.y;
                    selW = c.w;
                    selH = c.h;
                    break;
                }
        }
        function rsel(s: real): int {
            return Math.round(s * screen.devicePixelRatio);
        }
        function exec(): void {
            Quickshell.execDetached([
                "grim",
                "-g", `${rsel(selX)},${rsel(selY)} ${rsel(selW)}x${rsel(selH)}`,
                "-t", "png",
                "/tmp/ram/" + `${helper.fmtDate("yyyy-MM-dd_hh-mm-ss.png")}`
            ]);

            root.popout.done();
        }

        onPositionChanged: e => {
            curX = e.x;
            curY = e.y;

            if (pressed) {
                selX = Math.min(preX,  curX);
                selY = Math.min(preY,  curY);
                selW = Math.abs(preX - curX);
                selH = Math.abs(preY - curY);
            } else
                over();
        }

        onPressed: e => {
            pressed = true;

            preX = e.x;
            preY = e.y;
        }

        onReleased: {
            pressed = false;

            exec();
        }

        ScreencopyView {
            anchors.fill: parent

            captureSource: root.screen
        }

        Rectangle {
            id: subback

            anchors.fill: parent

            visible: false

            color: config.background
        }

        Item {
            id: submask

            anchors.fill: parent

            visible: false

            layer.enabled: true

            Rectangle {
                x: root.selX
                y: root.selY

                implicitWidth:  root.selW
                implicitHeight: root.selH

                radius: root.pressed ? 0 : config.clientRounding
            }
        }

        MultiEffect {
            anchors.fill: parent

            source: subback

            maskEnabled:      true
            maskInverted:     true
            maskSource:       submask
            maskSpreadAtMin:  1
            maskThresholdMin: 0.5

            opacity: config.pickerOpacity
        }

        Component.onCompleted: {
            over();
        }

        Keys.onEscapePressed: {
            root.popout.done();
        }
    }

    component Picker: CustomWindow {
        id: root

        name: "picker"

        WlrLayershell.layer:         WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        anchors.top:    true
        anchors.bottom: true
        anchors.left:   true
        anchors.right:  true

        required property var popout

        PickerArea {
            screen: root.screen
            popout: root.popout
        }
    }

    component PickerAll: Item {
        id: root

        required property var popout

        Variants {
            model: Quickshell.screens

            Scope {
                id: subscope

                required property var modelData

                Picker {
                    screen: subscope.modelData
                    popout: root.popout
                }
            }
        }
    }

    CustomPopout {
        id: picker

        comp: Component {
            PickerAll {
                popout: picker
            }
        }
    }

    CustomShortcut {
        name:        "picker"
        description: "Start picker"

        onPressed: {
            picker.exec();
        }
    }

    CustomShortcut {
        name:        "incVolume"
        description: "Increase volume"

        onPressed: {
        }
    }

    CustomShortcut {
        name:        "decVolume"
        description: "Decrease volume"

        onPressed: {
        }
    }

    CustomShortcut {
        name:        "mute"
        description: "Mute"

        onPressed: {
        }
    }
}
