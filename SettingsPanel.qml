import QtQuick
import qs.Commons
import qs.Ui

KeyboardPanel {
  id: root
  property var settings: ({})

  signal closeRequested()
  signal settingChanged(string key, var value)

  readonly property var metricKeys: ["showCpu", "showCpuTemp", "showRam", "showGpu", "showGpuTemp"]

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

  function enabledMetricCount() {
    var count = 0
    for (var i = 0; i < metricKeys.length; i++) {
      if (boolSetting(metricKeys[i], true))
        count++
    }
    return count
  }

  // Keep at least one chip visible so settings remain reachable.
  function setMetricVisible(key, wantOn) {
    var currentlyOn = boolSetting(key, true)
    if (!wantOn && currentlyOn && enabledMetricCount() <= 1)
      return
    setBool(key, wantOn)
  }

  function canDisableMetric(key) {
    return !(boolSetting(key, true) && enabledMetricCount() <= 1)
  }

  readonly property color fg: bar ? bar.foreground : Color.foreground
  readonly property string fontFam: bar ? bar.fontFamily : Style.font.family
  readonly property real rowW: width > 0 ? Math.max(200, width - Style.space(28)) : Style.space(320)

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
        spacing: Style.space(6)
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

        // ---- Visibility -------------------------------------------------
        Text {
          text: "Visible chips"
          color: root.fg
          font.family: root.fontFam
          font.pixelSize: Style.font.bodySmall
          font.bold: true
          topPadding: Style.space(4)
        }
        SettingRow {
          rowWidth: root.rowW
          foreground: root.fg
          fontFamily: root.fontFam
          label: "CPU usage"
          showToggle: true
          toggleOn: root.boolSetting("showCpu", true)
          toggleEnabled: root.canDisableMetric("showCpu")
          onToggled: root.setMetricVisible("showCpu", !root.boolSetting("showCpu", true))
        }
        SettingRow {
          rowWidth: root.rowW
          foreground: root.fg
          fontFamily: root.fontFam
          label: "CPU temp"
          showToggle: true
          toggleOn: root.boolSetting("showCpuTemp", true)
          toggleEnabled: root.canDisableMetric("showCpuTemp")
          onToggled: root.setMetricVisible("showCpuTemp", !root.boolSetting("showCpuTemp", true))
        }
        SettingRow {
          rowWidth: root.rowW
          foreground: root.fg
          fontFamily: root.fontFam
          label: "RAM"
          showToggle: true
          toggleOn: root.boolSetting("showRam", true)
          toggleEnabled: root.canDisableMetric("showRam")
          onToggled: root.setMetricVisible("showRam", !root.boolSetting("showRam", true))
        }
        SettingRow {
          rowWidth: root.rowW
          foreground: root.fg
          fontFamily: root.fontFam
          label: "GPU usage"
          showToggle: true
          toggleOn: root.boolSetting("showGpu", true)
          toggleEnabled: root.canDisableMetric("showGpu")
          onToggled: root.setMetricVisible("showGpu", !root.boolSetting("showGpu", true))
        }
        SettingRow {
          rowWidth: root.rowW
          foreground: root.fg
          fontFamily: root.fontFam
          label: "GPU temp"
          showToggle: true
          toggleOn: root.boolSetting("showGpuTemp", true)
          toggleEnabled: root.canDisableMetric("showGpuTemp")
          onToggled: root.setMetricVisible("showGpuTemp", !root.boolSetting("showGpuTemp", true))
        }

        // ---- CPU --------------------------------------------------------
        Text {
          text: "CPU"
          color: root.fg
          font.family: root.fontFam
          font.pixelSize: Style.font.bodySmall
          font.bold: true
          topPadding: Style.space(8)
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

        // ---- RAM --------------------------------------------------------
        Text {
          text: "RAM"
          color: root.fg
          font.family: root.fontFam
          font.pixelSize: Style.font.bodySmall
          font.bold: true
          topPadding: Style.space(8)
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

        // ---- GPU --------------------------------------------------------
        Text {
          text: "GPU"
          color: root.fg
          font.family: root.fontFam
          font.pixelSize: Style.font.bodySmall
          font.bold: true
          topPadding: Style.space(8)
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
