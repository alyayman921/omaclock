import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

// Large desktop clock rendered on the bottom layer, behind every app window
// but above the wallpaper. Hot-reloads when config.json is edited.
Item {
  id: root

  // Bundled Apple-like font (Inter, OFL) so no system install is needed.
  FontLoader {
    id: bundledFont
    source: Qt.resolvedUrl("fonts/InterVariable.ttf")
  }

  readonly property string configPath: Quickshell.env("HOME") + "/.config/omarchy/plugins/ubeyidah.omaclock/config.json"

  readonly property var defaults: ({
    format: "HH:mm",
    showSeconds: false,
    fontFamily: "",
    fontWeight: 200,
    fontScale: 0.20,
    letterSpacing: -3,
    color: "#ffffff",
    opacity: 0.92,
    position: "center",
    xRatio: null,
    yRatio: null,
    namespace: "ubeyidah.omaclock"
  })

  property var settings: root.defaults
  property string _lastRaw: ""

  function applyRaw(raw) {
    if (!raw || String(raw).trim().length === 0) return
    if (raw === root._lastRaw) return
    root._lastRaw = raw
    try {
      var parsed = JSON.parse(raw)
      var merged = {}
      for (var k in root.defaults) merged[k] = root.defaults[k]
      for (var p in parsed) if (parsed.hasOwnProperty(p)) merged[p] = parsed[p]
      root.settings = merged
    } catch (e) {
      console.warn("omaclock: invalid config.json: " + e)
    }
  }

  Process {
    id: cfgProc
    command: ["cat", root.configPath]
    stdout: StdioCollector { onStreamFinished: root.applyRaw(text) }
    Component.onCompleted: running = true
  }

  // Poll so edits made through the symlink (inotify can't follow it) still apply.
  Timer {
    interval: 2000
    repeat: true
    running: true
    onTriggered: if (!cfgProc.running) cfgProc.running = true
  }

  // This Qt build only emits 12-hour (1-12) when an AP token is present,
  // otherwise `h` falls back to 24-hour. So for a 12-hour format without
  // AM/PM we render with AP and strip the suffix.
  function clockString(date, fmt) {
    if (/h/.test(fmt) && !/AP/i.test(fmt)) {
      return Qt.formatDateTime(date, fmt + " AP").replace(/\s*(AM|PM)$/i, "").trim()
    }
    return Qt.formatDateTime(date, fmt)
  }

  readonly property string activeFont: root.settings.fontFamily
    ? root.settings.fontFamily
    : bundledFont.name
  readonly property real xRatio: (typeof root.settings.xRatio === "number")
    ? root.settings.xRatio : 0.5
  readonly property real yRatio: (typeof root.settings.yRatio === "number")
    ? root.settings.yRatio
    : (root.settings.position === "top" ? 0.14
      : root.settings.position === "bottom" ? 0.86 : 0.5)

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: panel
      required property var modelData

      screen: modelData
      visible: true
      anchors { top: true; bottom: true; left: true; right: true }
      color: "transparent"
      updatesEnabled: true

      WlrLayershell.namespace: root.settings.namespace
      WlrLayershell.layer: WlrLayer.Bottom
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      exclusionMode: ExclusionMode.Ignore

      // No MouseArea: the window is click-through so desktop/wallpaper
      // interactions (e.g. double-click wallpaper switcher) still work.

      Item {
        id: surface
        anchors.fill: parent

        Text {
          id: clockText
          color: root.settings.color
          opacity: root.settings.opacity
          font.family: root.activeFont
          font.weight: root.settings.fontWeight
          font.pixelSize: Math.max(8, Math.round(surface.height * root.settings.fontScale))
          font.letterSpacing: root.settings.letterSpacing
          text: root.clockString(clock.date, root.settings.format)

          x: surface.width * root.xRatio - width / 2
          y: surface.height * root.yRatio - height / 2
        }

        SystemClock {
          id: clock
          precision: root.settings.showSeconds ? SystemClock.Seconds : SystemClock.Minutes
          onDateChanged: clockText.text = root.clockString(date, root.settings.format)
        }
      }
    }
  }
}
