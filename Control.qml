import QtQuick
import QtQuick.Controls
import Quickshell
import qs.Commons
import qs.Ui

// OmaClock bar widget: a button in the bar (like the plugin drawer) that opens
// a small panel to control the desktop clock rendered by this plugin's service
// entry point. Size, X, and Y are sliders; the clock color follows the theme
// automatically, can be pinned to any theme palette role, or set to a custom
// hex color. Every change applies to the clock live and is saved to
// ~/.config/omaclock/config.json.
BarWidget {
    // --- menu state ------------------------------------------------------------
    // --- actions ---------------------------------------------------------------

    id: root

    // Live handle to the clock service (same plugin, kind "service"). Services
    // sync before bar widgets register, but the retry covers any reload order.
    property var svc: null
    property bool menuOpen: false
    // Color editor state, synced from the service when the panel opens and kept
    // current by the buttons below.
    property string mode: "auto"
    property string colorRole: "bar.text"
    property string customColor: "#ffffff"
    // Index of the 3x3 position cell the clock currently sits in, or -1 while
    // a slider is being dragged. Live-synced so the grid highlight follows both
    // slider edits and direct cell clicks.
    readonly property int currentCell: {
        if (!root.svc)
            return -1;

        var col = Math.max(0, Math.min(2, Math.round(root.svc.xRatio * 3 - 0.5)));
        var row = Math.max(0, Math.min(2, Math.round(root.svc.yRatio * 3 - 0.5)));
        return row * 3 + col;
    }
    // The swatches always render live theme colors (Color.* is theme-reactive),
    // independently of the service handle.
    property var themeRoles: [{
        "role": "bar.text",
        "label": "Bar text"
    }, {
        "role": "foreground",
        "label": "Foreground"
    }, {
        "role": "background",
        "label": "Background"
    }, {
        "role": "accent",
        "label": "Accent"
    }, {
        "role": "muted",
        "label": "Muted"
    }, {
        "role": "urgent",
        "label": "Urgent"
    }, {
        "role": "popups.text",
        "label": "Popup text"
    }]

    function refreshService() {
        if (!root.bar || !root.bar.shell)
            return false;

        var s = root.bar.shell.serviceFor(root.moduleName);
        if (s) {
            root.svc = s;
            return true;
        }
        return false;
    }

    function open() {
        root.syncFromService();
        root.menuOpen = true;
    }

    function close() {
        root.menuOpen = false;
    }

    function syncFromService() {
        if (!root.svc)
            return ;

        root.mode = String(root.svc.settings.colorMode || "auto");
        root.colorRole = String(root.svc.settings.colorRole || "bar.text");
        root.customColor = String(root.svc.settings.color || "#ffffff");
    }

    function colorFor(role) {
        switch (String(role || "")) {
        case "bar.text":
            return Color.bar.text;
        case "popups.text":
            return Color.popups.text;
        case "foreground":
            return Color.foreground;
        case "background":
            return Color.background;
        case "accent":
            return Color.accent;
        case "urgent":
            return Color.urgent;
        case "muted":
            return Color.muted;
        default:
            return Color.bar.text;
        }
    }

    function contrastFor(c) {
        return (c.r * 0.299 + c.g * 0.587 + c.b * 0.114) > 0.6 ? "#101315" : "#ffffff";
    }

    function setMode(m) {
        root.mode = m;
        if (!root.svc)
            return ;

        if (m === "theme")
            root.svc.setColor("theme", root.colorRole, "");
        else if (m === "custom")
            root.svc.setColor("custom", root.colorRole, root.customColor || "#ffffff");
        else
            root.svc.setColor("auto", root.colorRole, "");
        root.svc.saveConfig();
    }

    function pickThemeColor(role) {
        root.colorRole = role;
        root.mode = "theme";
        if (root.svc) {
            root.svc.setColor("theme", role, "");
            root.svc.saveConfig();
        }
    }

    function applyCustomColor() {
        var c = String(root.customColor || "").trim();
        if (!/^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/.test(c))
            return ;

        root.mode = "custom";
        if (root.svc) {
            root.svc.setColor("custom", root.colorRole, c);
            root.svc.saveConfig();
        }
    }

    function setSlider(key, percent) {
        if (root.svc)
            root.svc.setField(key, percent / 100);

    }

    function persistSliders() {
        if (root.svc)
            root.svc.saveConfig();

    }

    function resetAll() {
        if (root.svc)
            root.svc.resetLayout();

    }

    function placeAt(cell) {
        var col = cell % 3;
        var row = Math.floor(cell / 3);
        if (root.svc) {
            root.svc.setField("xRatio", (col + 0.5) / 3);
            root.svc.setField("yRatio", (row + 0.5) / 3);
            root.svc.saveConfig();
        }
    }

    moduleName: "ubeyidah.omaclock"
    onBarChanged: {
        if (!refreshService())
            retryTimer.restart();

    }
    Component.onCompleted: {
        if (!refreshService())
            retryTimer.restart();

    }
    implicitWidth: button.implicitWidth
    implicitHeight: button.implicitHeight

    Timer {
        id: retryTimer

        interval: 250
        onTriggered: {
            if (!refreshService())
                restart();

        }
    }

    BarIconButton {
        id: button

        anchors.fill: parent
        bar: root.bar
        text: "\uf017"
        tooltipText: "OmaClock settings"
        onPressed: function(b) {
            if (b !== Qt.LeftButton)
                return ;

            if (root.menuOpen)
                root.close();
            else
                root.open();
        }
    }

    PopupCard {
        id: popup

        anchorItem: button
        owner: root
        bar: root.bar
        open: root.menuOpen
        contentWidth: popup.fittedContentWidth(Style.space(300))
        contentHeight: popup.fittedContentHeight(column.implicitHeight, Style.space(560))

        Column {
            // --- color -------------------------------------------------------------

            id: column

            anchors.fill: parent
            spacing: Style.space(8)

            Text {
                text: "OMA CLOCK"
                color: Color.popups.text
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                font.bold: true
            }

            Row {
                width: parent.width
                spacing: Style.space(6)

                Text {
                    text: "Size"
                    color: Color.popups.text
                    font.family: Style.font.family
                    font.pixelSize: Style.font.body
                    width: parent.width - sizeValue.implicitWidth - parent.spacing
                }

                Text {
                    id: sizeValue

                    text: Math.round(sizeSlider.liveValue) + "%"
                    color: Qt.darker(Color.popups.text, 1.4)
                    font.family: Style.font.family
                    font.pixelSize: Style.font.body
                }

            }

            PanelSlider {
                id: sizeSlider

                width: parent.width
                minimum: 5
                maximum: 45
                step: 1
                value: root.svc ? Math.round(root.svc.fontScale * 100) : 20
                onMoved: function(v) {
                    root.setSlider("fontScale", v);
                }
                onReleased: function() {
                    root.persistSliders();
                }
            }

            Row {
                width: parent.width
                spacing: Style.space(6)

                Text {
                    text: "X Position"
                    color: Color.popups.text
                    font.family: Style.font.family
                    font.pixelSize: Style.font.body
                    width: parent.width - xValue.implicitWidth - parent.spacing
                }

                Text {
                    id: xValue

                    text: Math.round(xSlider.liveValue) + "%"
                    color: Qt.darker(Color.popups.text, 1.4)
                    font.family: Style.font.family
                    font.pixelSize: Style.font.body
                }

            }

            PanelSlider {
                id: xSlider

                width: parent.width
                minimum: 0
                maximum: 100
                step: 1
                value: root.svc ? Math.round(root.svc.xRatio * 100) : 50
                onMoved: function(v) {
                    root.setSlider("xRatio", v);
                }
                onReleased: function() {
                    root.persistSliders();
                }
            }

            Row {
                width: parent.width
                spacing: Style.space(6)

                Text {
                    text: "Y Position"
                    color: Color.popups.text
                    font.family: Style.font.family
                    font.pixelSize: Style.font.body
                    width: parent.width - yValue.implicitWidth - parent.spacing
                }

                Text {
                    id: yValue

                    text: Math.round(ySlider.liveValue) + "%"
                    color: Qt.darker(Color.popups.text, 1.4)
                    font.family: Style.font.family
                    font.pixelSize: Style.font.body
                }

            }

            PanelSlider {
                id: ySlider

                width: parent.width
                minimum: 0
                maximum: 100
                step: 1
                value: root.svc ? Math.round(root.svc.yRatio * 100) : 50
                onMoved: function(v) {
                    root.setSlider("yRatio", v);
                }
                onReleased: function() {
                    root.persistSliders();
                }
            }

            Text {
                text: "POSITION"
                color: Color.popups.text
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                font.bold: true
                topPadding: Style.space(4)
            }

            Grid {
                width: parent.width
                columns: 3
                rows: 3
                spacing: Style.space(6)

                Repeater {
                    model: 9

                    delegate: Item {
                        required property int index
                        readonly property bool selected: root.currentCell === index

                        width: (parent.width - parent.spacing * 2) / 3
                        height: Style.space(22)

                        Rectangle {
                            anchors.fill: parent
                            radius: Math.max(2, Style.cornerRadius)
                            color: selected ? Style.selectedFill : "transparent"
                            border.width: 1
                            border.color: selected ? Color.accent : Qt.darker(Color.popups.text, 2.2)

                            Rectangle {
                                visible: selected
                                anchors.centerIn: parent
                                width: Style.space(5)
                                height: Style.space(5)
                                radius: height / 2
                                color: Color.accent
                            }

                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.placeAt(index)
                        }

                    }

                }

            }

            Text {
                text: "COLOR"
                color: Color.popups.text
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                font.bold: true
                topPadding: Style.space(4)
            }

            Row {
                width: parent.width
                spacing: Style.space(6)

                Button {
                    text: "Auto"
                    selected: root.mode === "auto"
                    foreground: Color.popups.text
                    horizontalPadding: Style.space(10)
                    verticalPadding: 4
                    fontSize: Style.font.bodySmall
                    onClicked: root.setMode("auto")
                }

                Button {
                    text: "Theme"
                    selected: root.mode === "theme"
                    foreground: Color.popups.text
                    horizontalPadding: Style.space(10)
                    verticalPadding: 4
                    fontSize: Style.font.bodySmall
                    onClicked: root.setMode("theme")
                }

                Button {
                    text: "Custom"
                    selected: root.mode === "custom"
                    foreground: Color.popups.text
                    horizontalPadding: Style.space(10)
                    verticalPadding: 4
                    fontSize: Style.font.bodySmall
                    onClicked: root.setMode("custom")
                }

            }

            Flow {
                visible: root.mode === "theme"
                width: parent.width
                spacing: Style.space(8)

                Repeater {
                    model: root.themeRoles

                    delegate: Item {
                        required property var modelData
                        readonly property string role: modelData.role
                        readonly property bool selected: root.colorRole === modelData.role

                        width: Style.space(30)
                        height: Style.space(30)

                        Rectangle {
                            anchors.fill: parent
                            radius: Math.max(2, Style.cornerRadius)
                            color: "transparent"
                            border.width: 2
                            border.color: parent.selected ? Color.accent : "transparent"
                            visible: parent.selected
                        }

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: Style.space(5)
                            radius: height / 2
                            color: root.colorFor(modelData.role)
                            border.width: 1
                            border.color: Qt.darker(root.colorFor(modelData.role), 1.6)
                        }

                        Text {
                            visible: parent.selected
                            anchors.centerIn: parent
                            text: "\u2713"
                            color: root.contrastFor(root.colorFor(modelData.role))
                            font.family: Style.font.family
                            font.pixelSize: Style.font.caption
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.pickThemeColor(modelData.role)
                        }

                    }

                }

            }

            Text {
                visible: root.mode === "theme"
                text: "Swatches track the active theme live."
                color: Qt.darker(Color.popups.text, 1.5)
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                font.italic: true
            }

            Row {
                visible: root.mode === "custom"
                width: parent.width
                spacing: Style.space(6)

                TextField {
                    id: colorField

                    width: parent.width - applyBtn.width - parent.spacing
                    foreground: Color.popups.text
                    accent: Color.accent
                    verticalPadding: Style.space(5)
                    text: root.customColor
                    placeholderText: "#ffffff"
                    font.family: Style.font.family
                    font.pixelSize: Style.font.body
                    onTextEdited: root.customColor = text
                    onAccepted: root.applyCustomColor()
                }

                Button {
                    id: applyBtn

                    text: "Apply"
                    foreground: Color.popups.text
                    horizontalPadding: Style.space(12)
                    verticalPadding: Style.space(5)
                    fontSize: Style.font.bodySmall
                    onClicked: root.applyCustomColor()
                }

            }

            Row {
                width: parent.width
                spacing: Style.space(8)

                Rectangle {
                    id: resetBtn

                    width: Style.space(88)
                    height: Style.space(26)
                    radius: Style.cornerRadius
                    color: Style.selectedFill

                    Text {
                        anchors.centerIn: parent
                        text: "RESET"
                        color: Color.foreground
                        font.family: Style.font.family
                        font.pixelSize: Style.font.body
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.resetAll()
                    }

                }

                Text {
                    text: "Resets size and position"
                    color: Qt.darker(Color.popups.text, 1.5)
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption
                    anchors.verticalCenter: resetBtn.verticalCenter
                    elide: Text.ElideRight
                    width: parent.width - resetBtn.width - parent.spacing
                }

            }

        }

    }

}
