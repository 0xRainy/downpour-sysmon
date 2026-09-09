import QtQuick
import qs.Commons
import qs.Ui

KeyboardPanel {
  id: root
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

  readonly property color fg: bar ? bar.foreground : Color.foreground
  readonly property string fontFam: bar ? bar.fontFamily : Style.font.family
  readonly property real rowW: Style.space(320)

  centerOnBar: false
  focusTarget: keyCatcher
  contentWidth: fittedContentWidth(Style.space(360))
  contentHeight: fittedContentHeight(bodyCol.implicitHeight + Style.space(12))

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
          color: root.fg
          font.family: root.fontFam
          font.pixelSize: Style.font.body
          font.bold: true
        }

        Text {
          text: "CPU"
          color: root.fg
          font.family: root.fontFam
          font.pixelSize: Style.font.caption
          opacity: 0.55
        }
        SettingRow {
          rowWidth: root.rowW
          foreground: root.fg
          fontFamily: root.fontFam
          label: "Usage alert"
          showStepper: true
          valueText: root.intSetting("cpuWarnPercent", 80) + "%"
          onStepped: function(delta) { root.bumpInt("cpuWarnPercent", delta, 50, 100, 80) }
        }
        SettingRow {
          rowWidth: root.rowW
          foreground: root.fg
          fontFamily: root.fontFam
          label: "Usage graph"
          showToggle: true
          toggleOn: root.boolSetting("showCpuGraph", true)
          onToggled: root.setBool("showCpuGraph", !root.boolSetting("showCpuGraph", true))
        }
        SettingRow {
          rowWidth: root.rowW
          foreground: root.fg
          fontFamily: root.fontFam
          label: "Temp alert"
          showStepper: true
          valueText: root.intSetting("cpuTempWarnC", 80) + "°C"
          onStepped: function(delta) { root.bumpInt("cpuTempWarnC", delta, 50, 110, 80) }
        }
        SettingRow {
          rowWidth: root.rowW
          foreground: root.fg
          fontFamily: root.fontFam
          label: "Temp graph"
          showToggle: true
          toggleOn: root.boolSetting("showCpuTempGraph", true)
          onToggled: root.setBool("showCpuTempGraph", !root.boolSetting("showCpuTempGraph", true))
        }

        Text {
          text: "RAM"
          color: root.fg
          font.family: root.fontFam
          font.pixelSize: Style.font.caption
          opacity: 0.55
        }
        SettingRow {
          rowWidth: root.rowW
          foreground: root.fg
          fontFamily: root.fontFam
          label: "Usage alert"
          showStepper: true
          valueText: root.intSetting("ramWarnPercent", 80) + "%"
          onStepped: function(delta) { root.bumpInt("ramWarnPercent", delta, 50, 100, 80) }
        }
        SettingRow {
          rowWidth: root.rowW
          foreground: root.fg
          fontFamily: root.fontFam
          label: "Usage graph"
          showToggle: true
          toggleOn: root.boolSetting("showRamGraph", true)
          onToggled: root.setBool("showRamGraph", !root.boolSetting("showRamGraph", true))
        }

        Text {
          text: "GPU"
          color: root.fg
          font.family: root.fontFam
          font.pixelSize: Style.font.caption
          opacity: 0.55
        }
        SettingRow {
          rowWidth: root.rowW
          foreground: root.fg
          fontFamily: root.fontFam
          label: "Usage alert"
          showStepper: true
          valueText: root.intSetting("gpuWarnPercent", 80) + "%"
          onStepped: function(delta) { root.bumpInt("gpuWarnPercent", delta, 50, 100, 80) }
        }
        SettingRow {
          rowWidth: root.rowW
          foreground: root.fg
          fontFamily: root.fontFam
          label: "Usage graph"
          showToggle: true
          toggleOn: root.boolSetting("showGpuGraph", true)
          onToggled: root.setBool("showGpuGraph", !root.boolSetting("showGpuGraph", true))
        }
        SettingRow {
          rowWidth: root.rowW
          foreground: root.fg
          fontFamily: root.fontFam
          label: "Temp alert"
          showStepper: true
          valueText: root.intSetting("gpuTempWarnC", 80) + "°C"
          onStepped: function(delta) { root.bumpInt("gpuTempWarnC", delta, 50, 110, 80) }
        }
        SettingRow {
          rowWidth: root.rowW
          foreground: root.fg
          fontFamily: root.fontFam
          label: "Temp graph"
          showToggle: true
          toggleOn: root.boolSetting("showGpuTempGraph", true)
          onToggled: root.setBool("showGpuTempGraph", !root.boolSetting("showGpuTempGraph", true))
        }
      }
    }
  }
}
