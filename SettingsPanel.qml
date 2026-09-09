import QtQuick
import qs.Commons
import qs.Ui

KeyboardPanel {
  id: root
  required property Item anchorItem
  required property var owner
  required property var bar
  property var settings: ({})

  signal closeRequested()
  signal settingChanged(string key, var value)

  function boolSetting(key, fallback) {
    var value = settings ? settings[key] : undefined
    if (value === undefined || value === null)
      return fallback
    return !!value
  }

  function intSetting(key, fallback) {
    var value = settings ? settings[key] : undefined
    var n = parseInt(value, 10)
    return isNaN(n) ? fallback : n
  }

  function setBool(key, value) {
    root.settingChanged(key, !!value)
  }

  function bumpInt(key, delta, min, max, fallback) {
    var next = intSetting(key, fallback) + delta
    if (next < min) next = min
    if (next > max) next = max
    root.settingChanged(key, next)
  }

  centerOnBar: false
  focusTarget: keyCatcher
  contentWidth: fittedContentWidth(Style.space(360))
  contentHeight: fittedContentHeight(bodyCol.implicitHeight + Style.space(12))

  component SettingRow: Item {
    id: rowRoot
    property string label: ""
    property string valueText: ""
    property bool showStepper: false
    property bool showToggle: false
    property bool toggleOn: false
    signal stepped(int delta)
    signal toggled()

    width: bodyCol.width - bodyCol.leftPadding - bodyCol.rightPadding
    height: Style.space(28)

    Text {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      text: rowRoot.label
      color: root.bar ? root.bar.foreground : Color.foreground
      font.family: root.bar ? root.bar.fontFamily : Style.font.family
      font.pixelSize: Style.font.bodySmall
    }

    Row {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      spacing: Style.space(6)

      Text {
        visible: rowRoot.showStepper
        text: rowRoot.valueText
        color: root.bar ? root.bar.foreground : Color.foreground
        font.family: root.bar ? root.bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.bodySmall
        anchors.verticalCenter: parent.verticalCenter
      }

      Rectangle {
        visible: rowRoot.showStepper
        width: Style.space(22)
        height: Style.space(22)
        radius: 4
        color: Qt.rgba(1, 1, 1, 0.08)
        Text {
          anchors.centerIn: parent
          text: "−"
          color: root.bar ? root.bar.foreground : Color.foreground
        }
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: rowRoot.stepped(-5)
        }
      }

      Rectangle {
        visible: rowRoot.showStepper
        width: Style.space(22)
        height: Style.space(22)
        radius: 4
        color: Qt.rgba(1, 1, 1, 0.08)
        Text {
          anchors.centerIn: parent
          text: "+"
          color: root.bar ? root.bar.foreground : Color.foreground
        }
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: rowRoot.stepped(5)
        }
      }

      Rectangle {
        visible: rowRoot.showToggle
        width: Style.space(44)
        height: Style.space(22)
        radius: 11
        color: rowRoot.toggleOn ? Qt.rgba(1, 1, 1, 0.28) : Qt.rgba(1, 1, 1, 0.08)
        Rectangle {
          width: Style.space(16)
          height: Style.space(16)
          radius: 8
          anchors.verticalCenter: parent.verticalCenter
          x: rowRoot.toggleOn ? parent.width - width - 3 : 3
          color: root.bar ? root.bar.foreground : Color.foreground
        }
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: rowRoot.toggled()
        }
      }
    }
  }

  PanelKeyCatcher {
    id: keyCatcher
    anchors.fill: parent
    onCloseRequested: root.closeRequested()

    Flickable {
      anchors.fill: parent
      contentWidth: width
      contentHeight: bodyCol.implicitHeight
      clip: true
      boundsBehavior: Flickable.StopAtBounds
      interactive: contentHeight > height

      Column {
        id: bodyCol
        width: parent.width
        spacing: Style.space(8)
        leftPadding: Style.space(14)
        rightPadding: Style.space(14)
        topPadding: Style.space(12)
        bottomPadding: Style.space(12)

        Text {
          text: "Sysmon settings"
          color: root.bar ? root.bar.foreground : Color.foreground
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.body
          font.bold: true
        }

        Text {
          text: "CPU"
          color: root.bar ? root.bar.foreground : Color.foreground
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.caption
          opacity: 0.55
        }
        SettingRow {
          label: "Usage alert"
          showStepper: true
          valueText: intSetting("cpuWarnPercent", 80) + "%"
          onStepped: function(delta) { root.bumpInt("cpuWarnPercent", delta, 50, 100, 80) }
        }
        SettingRow {
          label: "Usage graph"
          showToggle: true
          toggleOn: boolSetting("showCpuGraph", true)
          onToggled: root.setBool("showCpuGraph", !boolSetting("showCpuGraph", true))
        }
        SettingRow {
          label: "Temp alert"
          showStepper: true
          valueText: intSetting("cpuTempWarnC", 80) + "°C"
          onStepped: function(delta) { root.bumpInt("cpuTempWarnC", delta, 50, 110, 80) }
        }
        SettingRow {
          label: "Temp graph"
          showToggle: true
          toggleOn: boolSetting("showCpuTempGraph", true)
          onToggled: root.setBool("showCpuTempGraph", !boolSetting("showCpuTempGraph", true))
        }

        Text {
          text: "RAM"
          color: root.bar ? root.bar.foreground : Color.foreground
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.caption
          opacity: 0.55
        }
        SettingRow {
          label: "Usage alert"
          showStepper: true
          valueText: intSetting("ramWarnPercent", 80) + "%"
          onStepped: function(delta) { root.bumpInt("ramWarnPercent", delta, 50, 100, 80) }
        }
        SettingRow {
          label: "Usage graph"
          showToggle: true
          toggleOn: boolSetting("showRamGraph", true)
          onToggled: root.setBool("showRamGraph", !boolSetting("showRamGraph", true))
        }

        Text {
          text: "GPU"
          color: root.bar ? root.bar.foreground : Color.foreground
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.caption
          opacity: 0.55
        }
        SettingRow {
          label: "Usage alert"
          showStepper: true
          valueText: intSetting("gpuWarnPercent", 80) + "%"
          onStepped: function(delta) { root.bumpInt("gpuWarnPercent", delta, 50, 100, 80) }
        }
        SettingRow {
          label: "Usage graph"
          showToggle: true
          toggleOn: boolSetting("showGpuGraph", true)
          onToggled: root.setBool("showGpuGraph", !boolSetting("showGpuGraph", true))
        }
        SettingRow {
          label: "Temp alert"
          showStepper: true
          valueText: intSetting("gpuTempWarnC", 80) + "°C"
          onStepped: function(delta) { root.bumpInt("gpuTempWarnC", delta, 50, 110, 80) }
        }
        SettingRow {
          label: "Temp graph"
          showToggle: true
          toggleOn: boolSetting("showGpuTempGraph", true)
          onToggled: root.setBool("showGpuTempGraph", !boolSetting("showGpuTempGraph", true))
        }
      }
    }
  }
}
