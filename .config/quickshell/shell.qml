pragma ComponentBehavior: Bound

import Qt.labs.folderlistmodel

import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts

import QtQml.Models

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Services.Pam
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import Quickshell.Widgets

import 'root:/fuzzy.js' as Fuzzy


ShellRoot {
  component CustomWindow: PanelWindow {
    property string name: 'default'

    WlrLayershell.namespace: `quickshell-${name}`

    color: config.colorBackgroundTrans
  }

  component CustomPopoutWindow: CustomWindow {
    id: master

    WlrLayershell.exclusionMode: ExclusionMode.Normal
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    required property var popout

    property alias hoverCheck: hover.enabled
    property bool  hovered:    false

    HoverHandler {
      id: hover

      onHoveredChanged: {
        if (hovered)
          master.hovered = true
        else if (master.hovered)
          master.popout.done()
      }
    }
  }

  component CustomShortcut: GlobalShortcut {
    appid: 'quickshell'
  }

  component CustomText: Text {
    font.family:    config.fontFamily
    font.pointSize: config.fontSize

    color: config.colorForeground
  }

  component CustomTextMetrics: TextMetrics {
    font.family:    config.fontFamily
    font.pointSize: config.fontSize

    elide:      Qt.ElideRight
    elideWidth: parent.width
  }

  component CustomTextField: TextField {
    focus: true

    leftPadding:  height / 2
    rightPadding: height / 2

    font.family:    config.fontFamily
    font.pointSize: config.fontSizeLarge

    color: config.colorForeground

    cursorDelegate: Item {
      enabled: false
    }

    background: Rectangle {
      anchors.fill: parent

      radius: height / 2
      color:  config.colorBackgroundLightTrans
    }
  }

  component CustomListView: ListView {
    focus: true

    clip:  true

    orientation:  Qt.Vertical
    currentIndex: 0

    highlight: Rectangle {
      color: config.colorBackgroundLightTrans
    }

    highlightMoveDuration:    0
    highlightMoveVelocity:   -1
    highlightResizeDuration:  0
    highlightResizeVelocity: -1
  }

  component CustomPopout: Item {
    readonly property alias loader: loader

    function init(): void {
      loader.active = true
    }
    function done(): void {
      loader.active = false
    }

    required property var delegate

    Loader {
      id: loader

      active: false

      sourceComponent: delegate
    }
  }

  component GlobalConfig: Item {
    id: config

    visible: false

    property string wallDir:     'file:///home/gosh/.wall'
    property string shotDir:     '/tmp/ram/shot_'

    property int    clientRadius: 8
    property int    clientGap:    8

    readonly property color  colorForeground:           '#abb2bf'
    readonly property color  colorForegroundDark:       '#848b98'
    readonly property color  colorForegroundDarker:     '#5f6571'
    readonly property color  colorBackgroundLight:      '#31353f'
    readonly property color  colorBackground:           '#23272e'

    readonly property color  colorBackgroundFailed:     '#a0993939'
    readonly property color  colorBackgroundError:      '#a093691d'
    readonly property color  colorBackgroundMax:        '#a08a3fa0'

    readonly property color  colorBackgroundLightTrans: '#a031353f'
    readonly property color  colorBackgroundTrans:      '#c023272e'

    readonly property int    iconSize:              20
    readonly property int    iconSizeLarge:         28
    readonly property int    iconSizeHuge:          36
    readonly property int    iconSizeGigantic:      44
    readonly property string iconDefault:          'gnome-settings'

    readonly property string fontFamily:           'Cantarell'
    readonly property string fontFamilyMono:       'Fira Code'
    readonly property int    fontSizeMini:          7
    readonly property int    fontSizeTiny:          8
    readonly property int    fontSizeSmall:         9
    readonly property int    fontSize:              10
    readonly property int    fontSizeLarge:         12
    readonly property int    fontSizeHuge:          64

    readonly property int    lineWidth:             1

    readonly property int    itemWidth:             48
    readonly property int    itemHeight:            28
    readonly property int    itemHeightLarge:       32
    readonly property int    itemHeightHuge:        36
    readonly property int    itemHeightGigantic:    56
    readonly property int    itemShown:             5

    readonly property int    paddingSmall:          2
    readonly property int    padding:               4
    readonly property int    paddingLarge:          6
    readonly property int    paddingHuge:           8
    readonly property int    paddingGigantic:       10

    readonly property int    windowWidth:           320
    readonly property int    windowWidthLarge:      480
    readonly property real   windowInactiveOpacity: 0.75
    readonly property int    windowTimeout:         2
  }

  component GlobalHelper: Item {
    id: helper

    visible: false

    // icon
    readonly property string iconDefault:
      Quickshell.iconPath(config.iconDefault, true)

    function getIcon(str: string): string {
      const ret = Quickshell.iconPath(str, true)

      if (ret.length)
        return ret

      return iconDefault
    }
    function getIconSum(str: string): string {
      if (str.includes('welcome'))
          return 'waving_hand'
      if (str.includes('recording'))
          return 'screen_record'
      if (str.includes('screenshot'))
          return 'screenshot_monitor'
      if (str.includes('time'))
          return 'schedule'
      if (str.includes('installed'))
          return 'download'
      if (str.includes('update'))
          return 'update'
      if (str.includes('unable to'))
          return 'deployed_code_alert'
      if (str.includes('reboot'))
          return 'restart_alt'
      if (str.includes('file'))
          return 'folder_copy'
      if (str.includes('profile'))
          return 'person'

      return config.iconDefault
    }

    // apps
    readonly property var apps:
      DesktopEntries.applications.values
        .filter( a     => !a.noDisplay)
        .sort  ((a, b) =>  a.name.localeCompare(b.name))
        .map   ( a     => ({
          name:    Fuzzy.prepare(a.name),
          comment: Fuzzy.prepare(a.comment),
          entry:   a
        }))

    function getApp(str: string): var {
      return Fuzzy.go(str, apps, {
        all:    true,
        keys: ['name', 'comment'],

        scoreFn: e => (e[0].score > 0.0) ?
                      (e[0].score * 0.9  +
                       e[1].score * 0.1) : 0

      }).map(e => e.obj.entry)
    }

    // time
    SystemClock {
      id: clock

      precision: SystemClock.Seconds
    }

    function fmtDate(fmt: string): string {
      return Qt.formatDateTime(clock.date, fmt)
    }
    function fmtDateYM(fmt: string, y: int, m: int): string {
      return Qt.formatDateTime(new Date(y, m), fmt)
    }

    // notif
    readonly property alias evts: server.trackedNotifications

    NotificationServer {
      id: server

      keepOnReload: true

      actionsSupported:        true
      bodyHyperlinksSupported: true
      bodyImagesSupported:     true
      bodyMarkupSupported:     true
      imageSupported:          true

      onNotification: ent => {
        ent.tracked = true
        shower.init()
      }
    }

    // audio
    readonly property var pwas: Pipewire.defaultAudioSink

    function setVol(val: int): void {
      if (pwas?.ready && pwas?.audio) {
        pwas.audio.muted = !pwas.audio.muted && (val === 0)

        const inc = pwas.audio.volume + (val / 100)

        if (inc >= 1)
          pwas.audio.volume = 1
        else if (inc <= 0)
          pwas.audio.volume = 0
        else
          pwas.audio.volume = inc
      }
    }

    readonly property real vol: {
      if (pwas?.ready && pwas?.audio)
        return pwas.audio.muted ? 0 : pwas.audio.volume
      else
        return 0
    }

    PwObjectTracker {
      objects: [pwas]
    }

    // hypr
    Connections {
      target: Hyprland

      function onRawEvent(evt: HyprlandEvent): void {
        if (evt.name.endsWith('v2'))
          return

        if (evt.name.includes('mon'))
          Hyprland.refreshMonitors()
        else if (evt.name.includes('workspace'))
          Hyprland.refreshWorkspaces()
        else
          Hyprland.refreshToplevels()
      }
    }

    readonly property var monitors:         Hyprland.monitors
    readonly property var workspaces:       Hyprland.workspaces
    readonly property var toplevels:        Hyprland.toplevels
    readonly property var focusedMonitor:   Hyprland.focusedMonitor
    readonly property var focusedWorkspace: Hyprland.focusedWorkspace
    readonly property var focusedToplevel:  Hyprland.activeToplevel

    readonly property int wsid: focusedWorkspace?.id ?? 1

    function putHypr(req: string): void {
      Hyprland.dispatch(req)
    }
  }

  GlobalConfig {
    id: config
  }

  GlobalHelper {
    id: helper
  }

  component PanelFocus: Column {
    id: master

    spacing: config.paddingGigantic

    property string icon: helper.getIcon('')

    IconImage {
      implicitSize: config.iconSize

      source: master.icon
    }

    CustomText {
      id: text

      text:  metric.elidedText
      width: master.width

      rotation: 90
    }

    CustomTextMetrics {
      id: metric

      elideWidth: master.height - config.paddingGigantic * 2

      onTextChanged: {
        master.icon = helper.getIcon(
          helper.focusedToplevel?.lastIpcObject.class ?? 'desktop')
      }

      text: helper.focusedToplevel?.title ?? qsTr('Desktop')
    }
  }

  component PanelWorkspaceItem: Rectangle {
    implicitWidth:  config.iconSizeLarge
    implicitHeight: config.iconSizeLarge

    required property int index
    required property var modelData

    radius: width / 2
    color: (helper.wsid === modelData.i) ?
             config.colorBackgroundLight :
            'transparent'

    CustomText {
      anchors.centerIn: parent

      color: config.colorForeground

      text: `${modelData.n}`
    }

    MouseArea {
      anchors.fill: parent

      enabled: helper.wsid !== modelData.i

      acceptedButtons: Qt.LeftButton | Qt.RightButton

      onClicked: {
        helper.putHypr(`vdesk ${modelData.i}`)
      }
    }
  }

  component PanelWorkspace: Column {
    id: master

    required property var screen

    // vdesk's ws numbering scheme
    readonly property var select:
      helper.workspaces.values.filter(w =>
        (w.monitor?.name === screen.name) &&
        (w.active || w.lastIpcObject.windows)
      ).map(w => ({
         i: w.id,
         n: Math.floor((w.id - 1) / helper.monitors.values.length) + 1
      }))

    Repeater {
      model: ScriptModel {
        values: master.select
      }

      PanelWorkspaceItem {}
    }
  }

  component PanelMenuItem: Rectangle {
    id: master

    implicitWidth:  config.windowWidth
    implicitHeight: master.modelData.isSeparator ?
                      1 : config.itemHeight

    color: master.modelData.isSeparator ?
             config.colorBackgroundLightTrans :
            'transparent'

    required property var modelData
    required property var popout

    Loader {
      id: widget

      active: !master.modelData.isSeparator

      sourceComponent: WrapperItem {
        implicitWidth:  config.windowWidth
        implicitHeight: config.itemHeight

        leftMargin:  config.padding
        rightMargin: config.padding

        RowLayout {
          Item {
            Layout.alignment: Qt.AlignVCenter

            implicitWidth:  config.iconSize
            implicitHeight: config.iconSize

            Loader {
              anchors.verticalCenter:   parent.verticalCenter
              anchors.horizontalCenter: parent.horizontalCenter

              active: master.modelData.buttonType ===
                        QsMenuButtonType.CheckBox

              sourceComponent: CheckBox {
                checked: master.modelData.checkState === Qt.Checked
              }
            }

            Loader {
              anchors.verticalCenter:   parent.verticalCenter
              anchors.horizontalCenter: parent.horizontalCenter

              active: master.modelData.buttonType ===
                        QsMenuButtonType.RadioButton

              sourceComponent: RadioButton {
                checked: master.modelData.checkState === Qt.Checked
              }
            }

            Loader {
              anchors.verticalCenter:   parent.verticalCenter
              anchors.horizontalCenter: parent.horizontalCenter

              active: master.modelData.icon.length &&
                     (master.modelData.buttonType ===
                        QsMenuButtonType.None)

              sourceComponent: IconImage {
                implicitSize: config.iconSize

                source: master.modelData.icon
              }
            }
          }

          Item {
            id: item

            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true

            implicitHeight: config.iconSize

            CustomText {
              anchors.verticalCenter: parent.verticalCenter

              color: master.modelData.enabled ?
                       config.colorForeground :
                       config.colorForegroundDarker

              text:  metric.elidedText
            }

            CustomTextMetrics {
              id: metric

              elideWidth: item.width

              text:  master.modelData.text
            }
          }

          Loader {
            Layout.alignment: Qt.AlignVCenter

            active: master.modelData.hasChildren

            sourceComponent: IconImage {
              implicitSize: config.iconSize

              source: helper.getIcon('arrow-down')
            }
          }
        }
      }
    }

    MouseArea {
      anchors.fill: parent

      hoverEnabled: true

      enabled: !master.modelData.isSeparator

      onEntered: {
        master.color = config.colorBackgroundLightTrans
      }
      onExited: {
        master.color = 'transparent'
      }
      onClicked: {
        if (!master.modelData.enabled || master.modelData.hasChildren)
          return

        master.modelData.triggered()
        master.popout.done()
      }
    }
  }

  component PanelMenuDelegator: DelegateChooser {
    id: master

    role: 'hasChildren'

    required property var popout

    DelegateChoice {
      roleValue: false

      PanelMenuItem {
        popout: master.popout
      }
    }

    DelegateChoice {
      roleValue: true

      Column {
        id: column

        required property var modelData

        PanelMenuItem {
          modelData: column.modelData
          popout:    master.popout
        }

        PanelMenu {
          modelData: column.modelData
          delegator: master
        }
      }
    }
  }

  component PanelMenu: Item {
    id: master

    implicitWidth:  widget.implicitWidth
    implicitHeight: widget.implicitHeight

    required property var modelData
    required property var delegator

    QsMenuOpener {
      id: opener

      menu: master.modelData
    }

    Column {
      id: widget

      Repeater {
        model: opener.children

        delegate: delegator
      }
    }
  }

  component PanelTrayMenu: CustomPopoutWindow {
    id: master

    anchors.left:   true
    anchors.bottom: true

    margins.left:   config.clientGap / screen.devicePixelRatio
    margins.bottom: config.clientGap / screen.devicePixelRatio

    implicitWidth:  widget.implicitWidth
    implicitHeight: widget.implicitHeight

    required property var modelData

    Item {
      id: widget

      focus: true

      implicitWidth:  menu.implicitWidth
      implicitHeight: menu.implicitHeight

      PanelMenu {
        id: menu

        modelData: master.modelData

        delegator: PanelMenuDelegator {
          popout:  master.popout
        }
      }

      Keys.onEscapePressed: {
        master.popout.done()
      }
    }
  }

  component PanelTrayItem: Item {
    id: master

    implicitWidth:  widget.implicitWidth
    implicitHeight: widget.implicitHeight

    required property int index
    required property var modelData

    IconImage {
      id: widget

      implicitSize: config.iconSize

      source: master.modelData.icon
    }

    CustomPopout {
      id: custom

      delegate: Component {
        PanelTrayMenu {
          modelData: master.modelData.menu
          popout:    custom
        }
      }
    }

    MouseArea {
      anchors.fill: parent

      acceptedButtons: Qt.LeftButton | Qt.RightButton

      onClicked: evt => {
        if (evt.button === Qt.LeftButton)
          master.modelData.activate()

        else if (master.modelData.menu)
          custom.init()
      }
    }
  }

  component PanelTray: Loader {
    active: SystemTray.items.values.length

    sourceComponent: Column {
      spacing: config.paddingGigantic

      Repeater {
        model: ScriptModel {
          values: [...SystemTray.items.values]
        }

        PanelTrayItem {}
      }
    }
  }

  component PanelAudio: Item {
    id: master

    required property var screen

    implicitWidth:  widget.implicitWidth
    implicitHeight: widget.implicitHeight

    IconImage {
      id: widget

      implicitSize: config.iconSize

      source: {
        const vol =  helper.vol
        const src = (vol === 0   ) ? 'audio-volume-muted'  :
                    (vol  <  0.33) ? 'audio-volume-low'    :
                    (vol  <  0.66) ? 'audio-volume-medium' :
                                     'audio-volume-high'

        return helper.getIcon(src)
      }
    }

    MouseArea {
      anchors.fill: parent

      acceptedButtons: Qt.LeftButton | Qt.RightButton

      onClicked: {
        volume.init(0, screen)
      }

      onWheel: evt => {
        volume.init(evt.angleDelta.y > 0 ? 10 : -10, screen)
      }
    }
  }

  component PanelCalendarMenu: CustomPopoutWindow {
    id: master

    anchors.left:   true
    anchors.bottom: true

    margins.left:   config.clientGap / screen.devicePixelRatio
    margins.bottom: config.clientGap / screen.devicePixelRatio

    implicitWidth:  widget.implicitWidth  + config.paddingHuge * 2
    implicitHeight: widget.implicitHeight + config.paddingHuge * 2

    ColumnLayout {
      id: widget

      anchors.centerIn: parent

      focus: true

      RowLayout {
        Layout.row:        0
        Layout.column:     1
        Layout.fillWidth:  true
        Layout.fillHeight: true

        IconImage {
          implicitSize: config.iconSize

          source: helper.getIcon('arrow-left')

          MouseArea {
            anchors.fill: parent

            onClicked: {
              if (grid.month === 0) {
                grid.month  = 11
                grid.year  -= 1
              } else
                grid.month -= 1
            }
          }
        }

        Item {
          Layout.fillWidth:  true
          Layout.fillHeight: true

          CustomText {
            anchors.centerIn: parent

            font.bold:      true
            font.pointSize: config.fontSizeLarge

            text: helper.fmtDateYM('MMMM yyyy', grid.year, grid.month)
          }
        }

        IconImage {
          implicitSize: config.iconSize

          source: helper.getIcon('arrow-right')

          MouseArea {
            anchors.fill: parent

            onClicked: {
              if (grid.month === 11) {
                grid.month  = 0
                grid.year  += 1
              } else
                grid.month += 1
            }
          }
        }
      }

      DayOfWeekRow {
        id: days

        Layout.fillWidth: true

        // HACK
        Layout.leftMargin:   config.padding
        Layout.rightMargin: -config.padding

        delegate: CustomText {
          required property var model

          font.bold: true

          color: config.colorForegroundDarker

          text: model.shortName
        }
      }

      MonthGrid {
        id: grid

        Layout.fillWidth: true

        delegate: Rectangle {
          id: day

          required property var model

          implicitWidth:  config.iconSizeLarge
          implicitHeight: config.iconSizeLarge

          radius: width / 2
          color:  model.today ?
                    config.colorBackgroundLight :
                   'transparent'

          CustomText {
            anchors.centerIn: parent

            color: (day.model.month === grid.month) ?
                     config.colorForeground :
                     config.colorForegroundDarker

            text: Qt.formatDate(day.model.date, 'd')
          }
        }
      }

      Keys.onEscapePressed: {
        master.popout.done()
      }
    }
  }

  component PanelCalendar: Item {
    implicitWidth:  widget.implicitWidth
    implicitHeight: widget.implicitHeight

    ColumnLayout {
      id: widget

      anchors.horizontalCenter: parent.horizontalCenter

      spacing: config.padding

      CustomText {
        Layout.alignment: Qt.AlignHCenter

        font.family:    config.fontFamilyMono
        font.pointSize: config.fontSizeTiny

        text: helper.fmtDate('hh:mm')
      }

      CustomText {
        Layout.alignment: Qt.AlignHCenter

        font.family:    config.fontFamilyMono
        font.pointSize: config.fontSizeMini

        text: helper.fmtDate('MMM dd')
      }
    }

    CustomPopout {
      id: custom

      delegate: Component {
        PanelCalendarMenu {
          popout: custom
        }
      }
    }

    MouseArea {
      anchors.fill: parent

      acceptedButtons: Qt.LeftButton | Qt.RightButton

      onClicked: {
        custom.init()
      }
    }
  }

  component Panel: CustomWindow {
    id: master

    WlrLayershell.exclusionMode: ExclusionMode.Auto
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.layer:         WlrLayer.Bottom

    anchors.left:   true
    anchors.top:    true
    anchors.bottom: true

    implicitWidth: config.itemWidth

    ColumnLayout {
      anchors.fill: parent

      spacing: config.paddingGigantic

      PanelFocus {
        Layout.alignment:    Qt.AlignHCenter
        Layout.topMargin:    config.clientGap

        Layout.fillHeight:   true
      }

      PanelWorkspace {
        Layout.alignment:    Qt.AlignHCenter

        screen: master.screen
      }

      PanelTray {
        Layout.alignment:    Qt.AlignHCenter
      }

      PanelAudio {
        Layout.alignment:    Qt.AlignHCenter

        screen: master.screen
      }

      // network will soon happen

      PanelCalendar {
        Layout.alignment:    Qt.AlignHCenter
        Layout.bottomMargin: config.clientGap
      }
    }
  }

  component Wallpaper: CustomWindow {
    id: master

    name: 'wallpaper'

    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer:         WlrLayer.Background

    anchors.left:   true
    anchors.right:  true
    anchors.top:    true
    anchors.bottom: true

    function getRand() {
      return model.get(Math.floor(Math.random() * model.count), 'fileUrl')
    }

    FolderListModel {
      id: model

      folder: config.wallDir

      showDirs:  false
      showFiles: true

      nameFilters: ['*.jpg', '*.jpeg', '*.png']

      onStatusChanged: {
        if (status === FolderListModel.Ready)
          timer.start()
      }
    }

    Timer {
      id: timer

      repeat:   true
      running:  false
      interval: 30 * 60 * 1000

      triggeredOnStart: true

      onTriggered: {
        image.source = master.getRand()
      }
    }

    Image {
      id: image

      anchors.fill: parent

      scale:   1
      opacity: 1
    }
  }

  Variants {
    model: Quickshell.screens

    Scope {
      id: scope

      required property var modelData

      Panel {
        screen: scope.modelData
      }

      Wallpaper {
        screen: scope.modelData
      }
    }
  }

  component PickerItem: WrapperMouseArea {
    id: master

    required property int index
    required property var modelData
    required property var list

    implicitWidth:  config.windowWidthLarge
    implicitHeight: config.itemHeightGigantic

    leftMargin:  config.padding
    rightMargin: config.padding

    hoverEnabled: true

    onEntered: {
      list.currentIndex = index
    }
    onClicked: {
      master.modelData.execute()
      list.popout.done()
    }

    RowLayout {
      spacing: config.paddingHuge

      IconImage {
        Layout.alignment: Qt.AlignVCenter

        implicitSize: config.iconSizeGigantic

        source: helper.getIcon(master.modelData?.icon)
      }

      Column {
        id: column

        Layout.alignment: Qt.AlignVCenter
        Layout.fillWidth: true

        CustomText {
          font.pointSize: config.fontSizeLarge

          text:  master.modelData?.name ?? ''
        }

        CustomText {
          color: config.colorForegroundDarker

          text:  metric.elidedText
        }

        CustomTextMetrics {
          id: metric

          elideWidth: column.width

          text: (master.modelData?.comment || master.modelData?.name) ?? ''
        }
      }
    }
  }

  component PickerList: CustomListView {
    id: master

    implicitWidth:  config.windowWidthLarge
    implicitHeight: config.itemHeightGigantic * config.itemShown

    required property var name
    required property var popout

    model: ScriptModel {
      values: helper.getApp(name)

      onValuesChanged: {
        if (values.length)
          currentIndex = 0
      }
    }

    delegate: Component {
      PickerItem {
        list: master
      }
    }
  }

  component Picker: CustomPopoutWindow {
    id: master

    anchors.bottom: true
    margins.bottom: config.clientGap / screen.devicePixelRatio

    implicitWidth:  widget.implicitWidth
    implicitHeight: widget.implicitHeight

    Column {
      id: widget

      Item {
        implicitWidth:  config.windowWidthLarge
        implicitHeight: config.itemHeightGigantic

        CustomTextField {
          id: text

          anchors.centerIn: parent

          implicitWidth:  config.windowWidth
          implicitHeight: config.itemHeightGigantic / 1.6

          onAccepted: {
            const curr = list.currentItem

            if (curr) {
              curr.modelData.execute()
              master.popout.done()
            }
          }
        }
      }

      PickerList {
        id: list

        name:   text.text
        popout: master.popout
      }

      Keys.onUpPressed: {
        list.decrementCurrentIndex()
      }
      Keys.onDownPressed: {
        list.incrementCurrentIndex()
      }
      Keys.onEscapePressed: {
        master.popout.done()
      }
    }
  }

  CustomPopout {
    id: picker

    delegate: Component {
      Picker {
        popout: picker
      }
    }
  }

  CustomShortcut {
    name:        'picker'
    description: 'Start picker'

    onPressed: {
      picker.init()
    }
  }

  component LockerSurface: WlSessionLockSurface {
    id: master

    required property var locker

    ScreencopyView {
      id: screen

      anchors.fill: parent

      captureSource: master.screen

      Component.onCompleted: {
        captureFrame()
      }
    }

    MultiEffect {
      id: effect

      anchors.fill: parent

      enabled: screen.hasContent
      source:  screen

      autoPaddingEnabled: false

      blurEnabled:    true
      blur:           1
      blurMax:        64
      blurMultiplier: 2
    }

    PamContext {
      id: pam

      property string reason: ''

      onResponseRequiredChanged: {
        if (!responseRequired)
          return

        respond(widget.text)
      }

      onCompleted: res => {
        widget.text = ''

        switch (res) {
          case PamResult.Success:
            master.locker.locked = false
            return
          case PamResult.Error:
            reason = 'error'
            break
          case PamResult.MaxTries:
            reason = 'max'
            break
          case PamResult.Failed:
            reason = 'failed'
            break
        }
      }
    }

    Column {
      anchors.centerIn: parent

      spacing: config.paddingHuge

      CustomText {
        anchors.horizontalCenter: parent.horizontalCenter

        font.pointSize: config.fontSizeHuge

        style:     'Raised'
        styleColor: config.colorBackground

        text: helper.fmtDate('hh:mm')
      }

      CustomTextField {
        id: widget

        anchors.horizontalCenter: parent.horizontalCenter

        implicitWidth:  config.windowWidth
        implicitHeight: config.itemHeightLarge

        horizontalAlignment: TextEdit.AlignHCenter

        echoMode:          TextInput.Password
        passwordMaskDelay: 0

        background: Rectangle {
          anchors.fill: parent

          radius: height / 2
          color: {
            switch (pam.reason) {
              case 'error':
                return config.colorBackgroundError
              case 'max':
                return config.colorBackgroundMax
              case 'failed':
                return config.colorBackgroundFailed
              default:
                return config.colorBackgroundLightTrans
            }
          }
        }

        onTextChanged: {
          pam.reason = ''
        }

        onAccepted: {
          if (pam.active)
            return

          pam.start()
        }
      }
    }
  }

  component Locker: WlSessionLock {
    id: master

    locked: true

    required property var popout

    onLockedChanged: {
      if (!locked)
        popout.done()
    }

    LockerSurface {
      locker: master
    }
  }

  CustomPopout {
    id: locker

    delegate: Component {
      Locker {
        popout: locker
      }
    }
  }

  CustomShortcut {
    name:        'locker'
    description: 'Start locker'

    onPressed: {
      locker.init()
    }
  }

  component ShowerItem: Rectangle {
    id: master

    implicitWidth:  widget.implicitWidth
    implicitHeight: widget.implicitHeight

    color: {
      switch (modelData.urgency) {
        case NotificationUrgency.Critical:
          return config.colorBackgroundError
        case NotificationUrgency.Low:
          return config.colorBackgroundMax
        default:
          return 'transparent'
      }
    }

    required property int index
    required property var modelData
    required property var list

    WrapperMouseArea {
      id: widget

      implicitWidth:  config.windowWidth
      implicitHeight: config.itemHeightGigantic

      leftMargin:  config.padding
      rightMargin: config.padding

      hoverEnabled: true

      acceptedButtons: Qt.LeftButton | Qt.RightButton

      onEntered: {
        master.list.currentIndex = index
      }
      onClicked: e => {
        if (e.button === Qt.LeftButton)
          for (const a of master.modelData.actions)
            a.invoke()

        master.modelData.tracked = false
      }

      RowLayout {
        spacing: config.padding

        Loader {
          Layout.alignment: Qt.AlignVCenter

          active: master.modelData.image.length

          sourceComponent: Item {
            implicitWidth:  config.iconSizeGigantic
            implicitHeight: config.iconSizeGigantic

            Image {
              anchors.fill: parent

              fillMode: Image.PreserveAspectCrop

              source: Qt.resolvedUrl(master.modelData.image)
            }
          }
        }

        Loader {
          Layout.alignment: Qt.AlignVCenter

          active: !master.modelData.image.length

          sourceComponent: IconImage {
            implicitSize: config.iconSizeGigantic

            source: {
              var str = master.modelData.appIcon ?? helper.getIconSum(
                        master.modelData.summary.toLowerCase())

              return helper.getIcon(str)
            }
          }
        }

        Column {
          id: column

          Layout.alignment: Qt.AlignVCenter
          Layout.fillWidth: true

          CustomText {
            font.pointSize: config.fontSizeLarge

            text:  metricMain.elidedText
          }

          CustomText {
            color: config.colorForegroundDarker

            text:  metricBody.elidedText
          }

          CustomTextMetrics {
            id: metricMain

            font.pointSize: config.fontSizeLarge

            elideWidth: column.width

            text:  master.modelData.summary
          }

          CustomTextMetrics {
            id: metricBody

            elideWidth: column.width

            text:  master.modelData.body.replace(/\n/g, ' | ')
          }
        }
      }
    }
  }

  component ShowerItemList: CustomListView {
    id: master

    implicitWidth:  config.windowWidth
    implicitHeight: config.itemHeightGigantic *
                    Math.min(config.itemShown,
                             helper.evts.values.length)

    required property var popout

    model: ScriptModel {
      values: helper.evts.values

      onValuesChanged: {
        if (values.length)
          master.currentIndex = 0
        else
          master.popout.done()
      }
    }

    delegate: Component {
      ShowerItem {
        list: master
      }
    }
  }

  component Shower: CustomPopoutWindow {
    id: master

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors.right:  true
    anchors.bottom: true

    margins.right:  config.clientGap / screen.devicePixelRatio
    margins.bottom: config.clientGap / screen.devicePixelRatio

    implicitWidth:  widget.implicitWidth
    implicitHeight: widget.implicitHeight

    hoverCheck: false

    ShowerItemList {
      id: widget

      popout: master.popout
    }
  }

  component ShowerAll: Item {
    id: master

    required property var popout

    Variants {
      model: Quickshell.screens

      Shower {
        required property var modelData

        screen: modelData
        popout: master.popout
      }
    }
  }

  CustomPopout {
    id: shower

    delegate: Component {
      ShowerAll {
        popout: shower
      }
    }
  }

  component ShoterArea: MouseArea {
    id: master

    anchors.fill: parent

    focus:        true
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

    property list<var> clients:
      helper.toplevels.values.filter(c =>
        c.workspace?.active &&
       (c.workspace.monitor.name === screen.name)
      ).map(c => conv(c)).sort((a, b) => a.t - b.t)

    function conv(c: var): var {
      const o = c.lastIpcObject
      const r = screen.devicePixelRatio

      return {
        x: (o.at  [0] - screen.x) / r,
        y: (o.at  [1] - screen.y) / r,
        w:  o.size[0]             / r,
        h:  o.size[1]             / r,

        t:  o.pinned ? 0 : o.floating ? 1 : 2
      }
    }
    function pick(): void {
      for (const c of clients)
        if ((c.x <= curX) && (c.x + c.w >= curX) &&
            (c.y <= curY) && (c.y + c.h >= curY)) {
          selX = c.x
          selY = c.y
          selW = c.w
          selH = c.h
          break
        }
    }
    function smag(s: real): int {
      return Math.round(s * screen.devicePixelRatio)
    }
    function exec(): void {
      Quickshell.execDetached([
          'grim',
          '-g', `${smag(selX)},${smag(selY)} ${smag(selW)}x${smag(selH)}`,
          '-t', 'png',
           config.shotDir + `${helper.fmtDate('yyyy-MM-dd_hh-mm-ss.png')}`
      ])

      master.popout.done()
    }

    onPositionChanged: e => {
      curX = e.x
      curY = e.y

      if (pressed) {
        selX = Math.min(preX,  curX)
        selY = Math.min(preY,  curY)
        selW = Math.abs(preX - curX)
        selH = Math.abs(preY - curY)
      } else
        pick()
    }

    onPressed: e => {
      pressed = true

      preX = e.x
      preY = e.y
    }

    onReleased: {
      pressed = false

      exec()
    }

    ScreencopyView {
      anchors.fill: parent

      captureSource: master.screen
    }

    Rectangle {
      id: over

      anchors.fill: parent

      visible: false

      color: config.colorBackground
    }

    Item {
      id: mask

      anchors.fill: parent

      visible:       false
      layer.enabled: true

      Rectangle {
        x: master.selX
        y: master.selY

        implicitWidth:  master.selW
        implicitHeight: master.selH

        radius: master.pressed ? 0 : config.clientRadius
      }
    }

    MultiEffect {
      anchors.fill: parent

      source: over

      maskEnabled:      true
      maskInverted:     true
      maskSource:       mask
      maskSpreadAtMin:  1
      maskThresholdMin: 0.5

      opacity: config.windowInactiveOpacity
    }

    Component.onCompleted: {
      pick()
    }

    Keys.onEscapePressed: {
      master.popout.done()
    }
  }

  component Shoter: CustomPopoutWindow {
    id: master

    name: 'picker'

    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.layer:         WlrLayer.Overlay

    anchors.top:    true
    anchors.bottom: true
    anchors.left:   true
    anchors.right:  true

    hoverCheck: false

    ShoterArea {
      screen: master.screen
      popout: master.popout
    }
  }

  component ShoterAll: Item {
    id: master

    required property var popout

    Variants {
      model: Quickshell.screens

      Shoter {
        required property var modelData

        screen: modelData
        popout: master.popout
      }
    }
  }

  CustomPopout {
    id: shoter

    delegate: Component {
      ShoterAll {
        popout: shoter
      }
    }
  }

  CustomShortcut {
    name:        'shoter'
    description: 'Start shoter'

    onPressed: {
      shoter.init()
    }
  }

  component Volume: CustomPopoutWindow {
    id: master

    required property var panel

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors.bottom: true

    margins.bottom: margin / screen.devicePixelRatio

    implicitWidth:  config.windowWidth
    implicitHeight: config.itemHeightLarge

    hoverCheck: false

    property real margin: screen.height * 0.1 - height / 2

    Rectangle {
      implicitWidth:  config.windowWidth * helper.vol
      implicitHeight: config.itemHeightLarge

      color: config.colorBackgroundLightTrans
    }

    Connections {
      target: helper

      function onVolChanged(): void {
          timer.restart()
      }
    }

    Timer {
      id: timer

      interval: config.windowTimeout * 1000
      running:  true

      onTriggered: {
          master.popout.done()
      }
    }

    Component.onCompleted: {
      if (master.panel)
        master.screen = master.panel
    }
  }

  CustomPopout {
    id: volume

    property var screen

    function init(val: int, screen: var): void {
      helper.setVol(val)

      if (loader.active == false)
        volume.screen = screen

      loader.active = true
    }

    delegate: Component {
      Volume {
        popout: volume
        panel:  volume.screen
      }
    }
  }

  CustomShortcut {
    name:        'incvol'
    description: 'Increase volume'

    onPressed: {
      volume.init(10)
    }
  }

  CustomShortcut {
    name:        'decvol'
    description: 'Decrease volume'

    onPressed: {
      volume.init(-10)
    }
  }

  CustomShortcut {
    name:        'mute'
    description: 'Mute'

    onPressed: {
      volume.init(0)
    }
  }
}
