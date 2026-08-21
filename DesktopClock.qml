import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.Commons

// Large desktop clock rendered on the bottom layer, behind every app window
// but above the wallpaper. Hot-reloads when config.json is edited.
Item {
  id: root

  // Bundled fonts (OFL) so no system install is needed. Inter is the default;
  // Plus Jakarta Sans is an opt-in family via `fontFamily`.
  FontLoader {
    id: bundledFont
    source: Qt.resolvedUrl("fonts/InterVariable.ttf")
  }
  FontLoader {
    id: appleFont
    source: Qt.resolvedUrl("fonts/PlusJakartaSans-Variable.ttf")
  }

  readonly property string configPath: Quickshell.env("HOME") + "/.config/omaclock/config.json"

  readonly property var defaults: ({
    format: "h:mm",
    showSeconds: false,
    fontFamily: "",
    fontWeight: 200,
    fontScale: 0.15,
    letterSpacing: -3,
    color: "",
    opacity: 0.92,
    position: "top",
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
  // AM/PM we render with AP and strip the suffix. A single-digit hour is
  // zero-padded so the prefix stays stable across minute ticks (e.g. the
  // config loads as `h:mm` but the initial paint uses the `HH:mm` default).
  function clockString(date, fmt) {
    if (/h/i.test(fmt) && !/AP/i.test(fmt)) {
      var s = Qt.formatDateTime(date, fmt + " AP").replace(/\s*(AM|PM)$/i, "").trim()
      return s.replace(/^(\d)(?=:)/, "0$1")
    }
    return Qt.formatDateTime(date, fmt)
  }

  // Font resolution: "system" uses the platform default font (empty family),
  // an explicit name is used as-is, and empty falls back to bundled Inter
  // ("Inter Variable" is the family name the bundled file registers).
  readonly property string activeFont: root.settings.fontFamily === "system"
    ? ""
    : (root.settings.fontFamily ? root.settings.fontFamily : "Inter Variable")

  // Empty `color` follows the top bar's text color (Color.bar.text), which is
  // theme- and wallpaper-aware. A non-empty value is an explicit override.
  readonly property color themeColor: Color.bar.text
  readonly property color activeColor: root.settings.color
    ? Qt.color(root.settings.color)
    : root.themeColor
  // Accept both JSON numbers and numeric strings ("0.3"), falling back when
  // the value is null/missing/garbage.
  function num(v, fallback) {
    if (v === null || v === undefined || v === "") return fallback
    var n = Number(v)
    return isNaN(n) ? fallback : n
  }

  readonly property real xRatio: root.num(root.settings.xRatio, 0.5)
  readonly property real yRatio: !isNaN(Number(root.settings.yRatio)) && root.settings.yRatio !== null && root.settings.yRatio !== ""
    ? Number(root.settings.yRatio)
    : (root.settings.position === "top" ? 0.20
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
      // Empty input region: without this, some Quickshell versions (0.3.x)
      // let the fullscreen surface capture mouse input, breaking desktop
      // interactions like Omarchy's double-click wallpaper switcher.
      mask: Region {}

      WlrLayershell.namespace: root.settings.namespace
      WlrLayershell.layer: WlrLayer.Bottom
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      exclusionMode: ExclusionMode.Ignore

      Item {
        id: surface
        anchors.fill: parent

        // Binding tracks clock.date directly, so format changes from
        // config hot-reload re-evaluate immediately (an imperative
        // onDateChanged assignment here would break this binding).
        Text {
          id: clockText
          color: root.activeColor
          opacity: Math.min(1, Math.max(0, root.num(root.settings.opacity, 0.92)))
          font.family: root.activeFont
          font.weight: root.settings.fontWeight
          font.pixelSize: Math.max(8, Math.round(surface.height * root.num(root.settings.fontScale, 0.15)))
          font.letterSpacing: root.settings.letterSpacing
          text: root.clockString(clock.date, root.settings.format)

          x: surface.width * root.xRatio - width / 2
          y: surface.height * root.yRatio - height / 2
        }

        SystemClock {
          id: clock
          precision: root.settings.showSeconds ? SystemClock.Seconds : SystemClock.Minutes
        }
      }
    }
  }
}
