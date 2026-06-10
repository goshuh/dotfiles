pragma ComponentBehavior: Bound

import Qt.labs.folderlistmodel

import QtCore
import QtWebSocketsExt

import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts

import QtQml.Models

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Networking
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

    HyprlandFocusGrab {
      id: grab

      windows: [master]

      active: master.WlrLayershell.keyboardFocus ===
                WlrKeyboardFocus.OnDemand

      onCleared: {
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

    property string homeDir:      StandardPaths.writableLocation(
                                  StandardPaths.HomeLocation)
    property string wallDir:      homeDir + '/.wall'
    property string shotDir:     '/tmp/ram/shot_'

    property int    clientRadius: 8
    property int    clientGap:    8

    readonly property color  colorForeground:           '#abb2bf'
    readonly property color  colorForegroundDark:       '#848b98'
    readonly property color  colorForegroundDarker:     '#5f6571'

    readonly property color  colorForegroundNorm:       '#80ffffff'
    readonly property color  colorForegroundRise:       '#80e06c75'
    readonly property color  colorForegroundFall:       '#8098c379'

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
    readonly property int    fontSizeLarger:        32
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

    readonly property string tradingView:
     'wss://data.tradingview.com/socket.io/websocket?from=chart&type=chart'
  }

  component GlobalHelper: Item {
    id: helper

    visible: false

    // misc
    function padLeft(str: string, len: int): string {
      if (str.length >= len)
        return str
      else
        return ' '.repeat(len - str.length) + str
    }
    function padRight(str: string, len: int): string {
      if (str.length >= len)
        return str.slice(0, len)
      else
        return str + ' '.repeat(len - str.length)
    }

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
        .filter(a     => !a.noDisplay)
        .sort ((a, b) =>  a.name.localeCompare(b.name))
        .map   (a     => ({
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

      onNotification: e => {
        e.tracked = true
        shower.init()
      }
    }

    // audio
    readonly property var audSink: Pipewire.defaultAudioSink

    readonly property var audSinks:   Pipewire.nodes.values.filter(n =>
      n.audio && !n.isStream &&  n.isSink
    )
    readonly property var audSources: Pipewire.nodes.values.filter(n =>
      n.audio && !n.isStream && !n.isSink
    )

    function setVol(val: int): void {
      if (!audSink?.ready || !audSink?.audio)
        return

      audSink.audio.muted = !audSink.audio.muted && (val === 0)

      const inc = audSink.audio.volume + (val / 100)

      if (inc >= 1)
        audSink.audio.volume = 1
      else if (inc <= 0)
        audSink.audio.volume = 0
      else
        audSink.audio.volume = inc
    }

    readonly property real vol: {
      if (!audSink?.ready || !audSink?.audio)
        return 0

      return audSink.audio.muted ? 0 : audSink.audio.volume
    }

    PwObjectTracker {
      objects: [audSink]
    }

    function getAudIcon(v: var): string {
      if (v === 0)
        return 'audio-volume-muted'
      if (v <  0.33)
        return 'audio-volume-low'
      if (v <  0.66)
        return 'audio-volume-medium'

      return 'audio-volume-high'
    }

    // network
    readonly property var netDevsWired: Networking.devices.values.filter(d =>
      d.type === DeviceType.Wired
    )

    readonly property var netWifiCons: {
      const arr = []

      for (const d of Networking.devices.values)
        if (d.type === DeviceType.Wifi)
          for (const n of d.networks.values)
            arr.push(n)

      return arr
    }

    function getWifiIcon(s: var): string {
      if (s >= 0.8)
        return 'network-wireless-signal-excellent'
      if (s >= 0.6)
        return 'network-wireless-signal-good'
      if (s >= 0.4)
        return 'network-wireless-signal-ok'
      if (s >= 0.2)
        return 'network-wireless-signal-weak'

      return 'network-wireless-signal-none'
    }

    // hypr
    Connections {
      target: Hyprland

      function onRawEvent(e: HyprlandEvent): void {
        if (e.name.endsWith('v2'))
          return

        if (e.name.includes('mon'))
          Hyprland.refreshMonitors()
        else if (e.name.includes('workspace'))
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

    // idle
    property bool idleLock: false

    Timer {
      id: idleTimer

      interval: 100 * 1000

      onTriggered: {
        helper.putHypr('hl.dsp.dpms("off")')
      }
    }

    IdleMonitor {
      timeout: 600

      onIsIdleChanged: {
        if (isIdle) {
          if (helper.idleLock === false)
            locker.init()

        } else {
          if (helper.idleLock === true)
            helper.reidle()
        }
      }
    }

    function idle(): void {
      idleLock = true
      idleTimer.start()
    }
    function reidle(): void {
      idleTimer.restart()
    }
    function unidle(): void {
      idleTimer.stop()
      idleLock = false
    }

    // stock
    property string stockQuote:   ''
    property string stockSession: ''
    property var    stockMap:    ({})
    property var    stocks:       []

    QtWebSocketsExt {
      id: socket

      active: false
      url:    config.tradingView

      onStatusChanged: s => {
        switch (s) {
          case QtWebSocketsExt.Open:
            helper.stockOpen()
            break

          case QtWebSocketsExt.Closed:
          case QtWebSocketsExt.Error:
            helper.stockClose()
            break
        }
      }

      onTextMessageReceived: msg => {
        helper.stockRecv(msg)
      }

      Component.onCompleted: {
        // the reason is here
        setHeader('Origin', 'https://www.tradingview.com')
      }
    }

    function stockInit(): void {
      if (socket.active)
        stockClose()

      const req = new XMLHttpRequest

      req.onreadystatechange = function() {
        if (req.readyState !== XMLHttpRequest.DONE)
          return

        const segs = []
        const syms = []

        for (const line of req.responseText.split(/\r?\n/)) {
          const item = line.trim()

          if (!item.length || item.startsWith('#'))
            continue
          else if (item.startsWith('sym: '))
            syms.push(item.slice(5).trim())
          else
            segs.push(line)
        }

        stockQuote = segs.join('\n')
        stocks     = syms.map(s => ({
          symbol:  s,
          price:   0,
          change:  0,
          percent: 0,
          ready:   false
        }))

        for (let i = 0; i < syms.length; i++)
          stockMap[syms[i]] = i

        stockSess()

        socket.active = true
      }

      req.open('GET', config.homeDir + '/.quote')
      req.send()
    }

    function stockSess(): void {
      const c = 'abcdefghijklmnopqrstuvwxyz' +
                'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
                '0123456789'

      stockSession = 'qs_'

      for (let i = 0; i < 12; i++)
        stockSession += c[Math.floor(Math.random() * c.length)]
    }

    function stockOpen(): void {
      helper.stockSend({
        m: 'set_auth_token',
        p: [
         'unauthorized_user_token'
        ]
      })

      helper.stockSend({
        m: 'quote_create_session',
        p: [
          stockSession
        ]
      })

      helper.stockSend({
        m: 'quote_set_fields',
        p: [
          stockSession,
         'rtc',
         'rch',
         'rchp'
        ]
      })

      for (const s of stocks) {
        helper.stockSend({
          m: 'quote_add_symbols',
          p: [
            stockSession,
            s.symbol
          ]
        })

        s.symbol = s.symbol.split(':')[1]
      }
    }

    function stockSend(msg: var): void {
      if (!socket.active)
        return

      const m = typeof msg === 'string' ? msg : JSON.stringify(msg)

      socket.sendTextMessage('~m~' + m.length + '~m~' + m)
    }

    function stockRecv(msg: string): void {
      if (!socket.active)
        return

      for (const s of msg.split(/~m~\d+~m~/)) {
        if (s.startsWith('~h~')) {
          helper.stockSend(s)
          continue
        }

        if (!s.length)
          continue

        try {
          const r = JSON.parse(s)

          if (!r || (r.m !== 'qsd'))
            continue

          const p = r.p[1]

          if (!p || (p.s !== 'ok'))
            continue

          const q = stocks[stockMap[p.n]]

          if (!q)
            continue

          q.price   = p.v.rtc  ?? q.price
          q.change  = p.v.rch  ?? q.change
          q.percent = p.v.rchp ?? q.percent
          q.ready   = true

          stocksChanged()

        } catch (e) {
          // ignore parse errors
        }
      }
    }

    function stockClose(): void {
      if (!socket.active)
        return

      helper.stockSend({
        m: 'quote_delete_session',
        p: [
          stockSession
        ]
      })

      socket.active = false
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
        // TODO: not working now
        helper.putHypr(`hl.dsp.window.vdesk(${modelData.i})`)
      }
    }
  }

  component PanelWorkspace: Column {
    id: master

    required property var screen

    spacing: config.padding

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

    property bool expanded: false

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

              source: helper.getIcon(master.expanded ? 'arrow-up' :
                                                       'arrow-down')
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
        if (!master.expanded)
          master.color = 'transparent'
      }
      onClicked: {
        if (!master.modelData.enabled)
          return

        if (master.modelData.hasChildren) {
          master.expanded = !master.expanded

          master.color = master.expanded ? config.colorBackgroundLightTrans :
                                          'transparent'
          return
        }

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
          id: leader

          modelData: column.modelData
          popout:    master.popout
        }

        PanelMenu {
          visible:   leader.expanded

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

      onClicked: e => {
        if (e.button === Qt.LeftButton)
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

  component PanelNetworkMenu: CustomPopoutWindow {
    id: master

    anchors.left:   true
    anchors.bottom: true

    margins.left:   config.clientGap / screen.devicePixelRatio
    margins.bottom: config.clientGap / screen.devicePixelRatio

    implicitWidth:  widget.implicitWidth
    implicitHeight: widget.implicitHeight

    Column {
      id: widget

      focus: true

      Rectangle {
        implicitWidth:  config.windowWidth
        implicitHeight: config.itemHeight

        color: 'transparent'

        CustomText {
          anchors.left:           parent.left
          anchors.leftMargin:     config.padding
          anchors.verticalCenter: parent.verticalCenter

          color: config.colorForegroundDarker

          text: 'Wired'
        }
      }

      Repeater {
        model: ScriptModel {
          values: helper.netDevsWired
        }

        delegate: Rectangle {
          id: wired

          required property var modelData

          implicitWidth:  config.windowWidth
          implicitHeight: config.itemHeight

          color: 'transparent'

          WrapperItem {
            implicitWidth:  config.windowWidth
            implicitHeight: config.itemHeight

            leftMargin:  config.padding
            rightMargin: config.padding

            RowLayout {
              Item {
                Layout.alignment: Qt.AlignVCenter

                implicitWidth:  config.iconSize
                implicitHeight: config.iconSize

                RadioButton {
                  anchors.centerIn: parent

                  checked: wired.modelData.connected
                }
              }

              Item {
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true

                implicitHeight: config.iconSize

                CustomText {
                  anchors.verticalCenter: parent.verticalCenter

                  text: wired.modelData.network ? wired.modelData.network.name :
                                                  wired.modelData.name
                }
              }
            }
          }

          MouseArea {
            anchors.fill: parent

            hoverEnabled: true

            onEntered: {
              wired.color = config.colorBackgroundLightTrans
            }
            onExited: {
              wired.color = 'transparent'
            }
            onClicked: {
              if (!wired.modelData.connected &&
                   wired.modelData.hasLink   &&
                   wired.modelData.network) {
                pending.target = wired.modelData.network
                wired.modelData.network.connect()
              }
            }
          }
        }
      }

      Rectangle {
        implicitWidth:  config.windowWidth
        implicitHeight: 1

        color: config.colorBackgroundLightTrans
      }

      Rectangle {
        implicitWidth:  config.windowWidth
        implicitHeight: config.itemHeight

        color: 'transparent'

        CustomText {
          anchors.left:           parent.left
          anchors.leftMargin:     config.padding
          anchors.verticalCenter: parent.verticalCenter

          color: config.colorForegroundDarker

          text: 'Wireless'
        }
      }

      Repeater {
        model: ScriptModel {
          values: helper.netWifiCons
        }

        delegate: Rectangle {
          id: wifi

          required property var modelData

          implicitWidth:  config.windowWidth
          implicitHeight: config.itemHeight

          color: 'transparent'

          WrapperItem {
            implicitWidth:  config.windowWidth
            implicitHeight: config.itemHeight

            leftMargin:  config.padding
            rightMargin: config.padding

            RowLayout {
              Item {
                Layout.alignment: Qt.AlignVCenter

                implicitWidth:  config.iconSize
                implicitHeight: config.iconSize

                RadioButton {
                  anchors.centerIn: parent

                  checked: wifi.modelData.connected
                }
              }

              Item {
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true

                implicitHeight: config.iconSize

                CustomText {
                  anchors.verticalCenter: parent.verticalCenter

                  text: wifi.modelData.name
                }
              }

              Loader {
                Layout.alignment: Qt.AlignVCenter

                active: !wifi.modelData.connected

                sourceComponent: IconImage {
                  implicitSize: config.iconSize

                  source: helper.getIcon(
                    helper.getWifiIcon(wifi.modelData.signalStrength))
                }
              }
            }
          }

          MouseArea {
            anchors.fill: parent

            hoverEnabled: true

            onEntered: {
              wifi.color = config.colorBackgroundLightTrans
            }
            onExited: {
              wifi.color = 'transparent'
            }
            onClicked: {
              if (!wifi.modelData.connected &&
                  !wifi.modelData.stateChanging) {
                pending.target = wifi.modelData
                wifi.modelData.connect()
              }
            }
          }
        }
      }

      Keys.onEscapePressed: {
        master.popout.done()
      }
    }

    Connections {
      id: pending

      target:  null
      enabled: target !== null

      function onConnectionFailed(r: var): void {
        if (r === ConnectionFailReason.NoSecrets) {
          passwd.init(master.screen, target)
          target = null
        }
      }
    }

    Component.onCompleted: {
      for (const d of Networking.devices.values)
        if (d.type === DeviceType.Wifi)
          d.scannerEnabled = true
    }

    Component.onDestruction: {
      for (const d of Networking.devices.values)
        if (d.type === DeviceType.Wifi)
          d.scannerEnabled = false
    }
  }

  component PanelNetwork: Item {
    id: master

    required property var screen

    implicitWidth:  widget.implicitWidth
    implicitHeight: widget.implicitHeight

    IconImage {
      id: widget

      implicitSize: config.iconSize

      source: {
        for (const d of helper.netDevsWired)
          if (d.connected)
            return helper.getIcon('network-wired')

        for (const n of helper.netWifiCons)
          if (n.connected)
            return helper.getIcon(helper.getWifiIcon(n.signalStrength))

        return helper.getIcon('network-offline')
      }
    }

    CustomPopout {
      id: custom

      delegate: Component {
        PanelNetworkMenu {
          popout: custom
        }
      }
    }

    MouseArea {
      anchors.fill: parent

      acceptedButtons: Qt.LeftButton | Qt.RightButton

      onClicked: e => {
        if (e.button === Qt.RightButton)
          custom.init()
      }
    }
  }

  component PanelAudioMenu: CustomPopoutWindow {
    id: master

    anchors.left:   true
    anchors.bottom: true

    margins.left:   config.clientGap / screen.devicePixelRatio
    margins.bottom: config.clientGap / screen.devicePixelRatio

    implicitWidth:  widget.implicitWidth
    implicitHeight: widget.implicitHeight

    Column {
      id: widget

      focus: true

      Rectangle {
        implicitWidth:  config.windowWidth
        implicitHeight: config.itemHeight

        color: 'transparent'

        CustomText {
          anchors.left:           parent.left
          anchors.leftMargin:     config.padding
          anchors.verticalCenter: parent.verticalCenter

          color: config.colorForegroundDarker

          text: 'Output'
        }
      }

      Repeater {
        model: ScriptModel {
          values: helper.audSinks
        }

        delegate: Rectangle {
          id: sink

          required property var modelData

          implicitWidth:  config.windowWidth
          implicitHeight: config.itemHeight

          color: 'transparent'

          WrapperItem {
            implicitWidth:  config.windowWidth
            implicitHeight: config.itemHeight

            leftMargin:  config.padding
            rightMargin: config.padding

            RowLayout {
              Item {
                Layout.alignment: Qt.AlignVCenter

                implicitWidth:  config.iconSize
                implicitHeight: config.iconSize

                RadioButton {
                  anchors.centerIn: parent

                  checked: sink.modelData === Pipewire.defaultAudioSink
                }
              }

              Item {
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true

                implicitHeight: config.iconSize

                CustomText {
                  anchors.verticalCenter: parent.verticalCenter

                  text: metric.elidedText
                }

                CustomTextMetrics {
                  id: metric

                  text: sink.modelData.description ||
                        sink.modelData.nickname    ||
                        sink.modelData.name
                }
              }
            }
          }

          MouseArea {
            anchors.fill: parent

            hoverEnabled: true

            onEntered: {
              sink.color = config.colorBackgroundLightTrans
            }
            onExited: {
              sink.color = 'transparent'
            }
            onClicked: {
              Pipewire.preferredDefaultAudioSink = sink.modelData
            }
          }
        }
      }

      Rectangle {
        implicitWidth:  config.windowWidth
        implicitHeight: 1

        color: config.colorBackgroundLightTrans
      }

      Rectangle {
        implicitWidth:  config.windowWidth
        implicitHeight: config.itemHeight

        color: 'transparent'

        CustomText {
          anchors.left:           parent.left
          anchors.leftMargin:     config.padding
          anchors.verticalCenter: parent.verticalCenter

          color: config.colorForegroundDarker

          text: 'Input'
        }
      }

      Repeater {
        model: ScriptModel {
          values: helper.audSources
        }

        delegate: Rectangle {
          id: source

          required property var modelData

          implicitWidth:  config.windowWidth
          implicitHeight: config.itemHeight

          color: 'transparent'

          WrapperItem {
            implicitWidth:  config.windowWidth
            implicitHeight: config.itemHeight

            leftMargin:  config.padding
            rightMargin: config.padding

            RowLayout {
              Item {
                Layout.alignment: Qt.AlignVCenter

                implicitWidth:  config.iconSize
                implicitHeight: config.iconSize

                RadioButton {
                  anchors.centerIn: parent

                  checked: source.modelData === Pipewire.defaultAudioSource
                }
              }

              Item {
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true

                implicitHeight: config.iconSize

                CustomText {
                  anchors.verticalCenter: parent.verticalCenter

                  text: metric.elidedText
                }

                CustomTextMetrics {
                  id: metric

                  text: source.modelData.description ||
                        source.modelData.nickname    ||
                        source.modelData.name
                }
              }
            }
          }

          MouseArea {
            anchors.fill: parent

            hoverEnabled: true

            onEntered: {
              source.color = config.colorBackgroundLightTrans
            }
            onExited: {
              source.color = 'transparent'
            }
            onClicked: {
              Pipewire.preferredDefaultAudioSource = source.modelData
            }
          }
        }
      }

      Keys.onEscapePressed: {
        master.popout.done()
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

      source: helper.getIcon(helper.getAudIcon(helper.vol))
    }

    CustomPopout {
      id: custom

      delegate: Component {
        PanelAudioMenu {
          popout: custom
        }
      }
    }

    MouseArea {
      anchors.fill: parent

      acceptedButtons: Qt.LeftButton | Qt.RightButton

      onClicked: e => {
        if (e.button === Qt.LeftButton)
          volume.init(0, screen)

        else if (e.button === Qt.RightButton)
          custom.init()
      }

      onWheel: e => {
        volume.init(e.angleDelta.y > 0 ? 10 : -10, screen)
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
              if (!grid.month) {
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
          color:  model.today ? config.colorBackgroundLight : 'transparent'

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

      PanelNetwork {
        Layout.alignment:    Qt.AlignHCenter

        screen: master.screen
      }

      PanelAudio {
        Layout.alignment:    Qt.AlignHCenter

        screen: master.screen
      }

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

  component Quote: CustomWindow {
    id: master

    name: 'quote'

    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer:         WlrLayer.Overlay

    anchors.right:  true
    anchors.bottom: true

    margins.right:  config.clientGap
    margins.bottom: config.clientGap

    implicitWidth:  widget.implicitWidth
    implicitHeight: widget.implicitHeight

    color: 'transparent'
    mask:   Region {}

    Column {
      id: widget

      anchors.right:  parent.right
      anchors.bottom: parent.bottom

      spacing: config.padding

      Repeater {
        model: ScriptModel {
          values: helper.stocks
        }

        Row {
          anchors.right: parent.right

          required property var modelData

          CustomText {
            font.family:    config.fontFamilyMono
            font.pointSize: config.fontSizeSmall

            color: config.colorForegroundNorm

            text: helper.padRight(modelData.symbol, 4)
          }

          CustomText {
            font.family:    config.fontFamilyMono
            font.pointSize: config.fontSizeSmall

            color: {
              const c = modelData.change

              if (c > 0)
                return config.colorForegroundRise
              else if (c < 0)
                return config.colorForegroundFall
              else
                return config.colorForegroundNorm
            }

            text: {
              if (!modelData.ready)
                return ' ----.-- ---.-- ---.--%'

              return helper.padLeft(modelData.price  .toFixed(2), 8) +
                     helper.padLeft(modelData.change .toFixed(2), 7) +
                     helper.padLeft(modelData.percent.toFixed(2), 7) + '%'
            }
          }
        }
      }

      Text {
        anchors.right: parent.right

        horizontalAlignment: Text.AlignRight

        color: config.colorForegroundNorm

        font.family:   'Source Han Sans CN'
        font.pointSize: config.fontSizeLarger

        lineHeightMode: Text.ProportionalHeight
        lineHeight:     0.8

        text: helper.stockQuote
      }
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

      Quote {
        screen: scope.modelData
      }

      Wallpaper {
        screen: scope.modelData
      }
    }

    Component.onCompleted: {
      helper.stockInit()
    }
  }

  CustomShortcut {
    name:        'qstart'
    description: 'Start quote'

    onPressed: {
      helper.stockInit()
    }
  }

  CustomShortcut {
    name:        'qstop'
    description: 'Stop quote'

    onPressed: {
      helper.stockStop()
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

      PickerList {
        id: list

        name:   text.text
        popout: master.popout
      }

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

          Component.onCompleted: {
            forceActiveFocus()
          }
        }
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

      onHasContentChanged: {
        if (hasContent)
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

      onCompleted: r => {
        widget.text = ''

        switch (r) {
          case PamResult.Success:
            master.locker.locked = false
            break
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

    IpcHandler {
      target: 'locker'

      function unlock(): void {
        if (pam.active)
          pam.abort()

        master.locker.locked = false
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

    Component.onCompleted: {
      helper.idle()

      Quickshell.execDetached([
       'loginctl', 'lock-session'
      ])
    }

    Component.onDestruction: {
      helper.unidle()
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
    description: 'Lock the screen'

    onPressed: {
      if (helper.idleLock === false)
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
        spacing: config.paddingGigantic

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

    property real offX: 0
    property real offY: 0

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

        p:  screen.x,
        q:  screen.y,

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
          offX = c.p
          offY = c.q
          break
        }
    }
    function smag(s: real): int {
      return Math.round(s * screen.devicePixelRatio)
    }
    function exec(): void {
      Quickshell.execDetached([
       'grim',
       '-g', `${smag(selX) + offX},${smag(selY) + offY} ` +
             `${smag(selW)}x${smag(selH)}`,
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

  component Passwd: CustomPopoutWindow {
    id: master

    required property var panel
    required property var network

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    anchors.bottom: true

    margins.bottom: config.clientGap / screen.devicePixelRatio

    implicitWidth:  config.windowWidthLarge
    implicitHeight: config.itemHeightGigantic

    CustomTextField {
      id: field

      anchors.centerIn: parent

      implicitWidth:  config.windowWidth
      implicitHeight: config.itemHeightGigantic / 1.6

      echoMode: TextInput.Password

      placeholderText:     "Password for " + (master.network?.name ?? "WiFi")
      placeholderTextColor: config.colorForegroundDarker

      onAccepted: {
        if (master.network)
          master.network.connectWithPsk(field.text)

        master.popout.done()
      }

      Keys.onEscapePressed: {
        master.popout.done()
      }
    }

    Component.onCompleted: {
      if (master.panel)
        master.screen = master.panel
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
    id: passwd

    property var screen
    property var network

    function init(screen: var, network: var): void {
      passwd.screen  = screen
      passwd.network = network
      loader.active  = true
    }

    delegate: Component {
      Passwd {
        popout:  passwd
        panel:   passwd.screen
        network: passwd.network
      }
    }
  }

  CustomPopout {
    id: volume

    property var screen

    function init(val: int, screen: var): void {
      helper.setVol(val)

      if (!loader.active)
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
