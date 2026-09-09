import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

BarWidget {
  id: root
  moduleName: "local.sysmon"

  property var sample: Model.emptySample()
  property var cpuHistory: []
  property var cpuTempHistory: []
  property var ramHistory: []
  property var gpuHistory: []
  property var gpuTempHistory: []
  property string detailMetric: "cpu"
  property bool detailVisible: false
  property bool settingsVisible: false

  readonly property color normalFg: bar ? bar.barForeground : Color.foreground
  readonly property color hotFg: bar && bar.urgent ? bar.urgent : Color.urgent

  readonly property int cpuWarnPercent: Model.clampInt(setting("cpuWarnPercent", 80), 50, 100, 80)
  readonly property int cpuTempWarnC: Model.clampInt(setting("cpuTempWarnC", 80), 50, 110, 80)
  readonly property int ramWarnPercent: Model.clampInt(setting("ramWarnPercent", 80), 50, 100, 80)
  readonly property int gpuWarnPercent: Model.clampInt(setting("gpuWarnPercent", 80), 50, 100, 80)
  readonly property int gpuTempWarnC: Model.clampInt(setting("gpuTempWarnC", 80), 50, 110, 80)

  readonly property bool showCpuGraph: setting("showCpuGraph", true) !== false
  readonly property bool showCpuTempGraph: setting("showCpuTempGraph", true) !== false
  readonly property bool showRamGraph: setting("showRamGraph", true) !== false
  readonly property bool showGpuGraph: setting("showGpuGraph", true) !== false
  readonly property bool showGpuTempGraph: setting("showGpuTempGraph", true) !== false

  readonly property bool showCpu: setting("showCpu", true) !== false
  readonly property bool showCpuTemp: setting("showCpuTemp", true) !== false
  readonly property bool showRam: setting("showRam", true) !== false
  readonly property bool showGpu: setting("showGpu", true) !== false && !!sample.gpu
  readonly property bool showGpuTemp: setting("showGpuTemp", true) !== false && sample.gpu && sample.gpu.tempC !== null && sample.gpu.tempC !== undefined

  readonly property bool opened: detailVisible || settingsVisible

  function pluginDir() {
    var u = String(Qt.resolvedUrl("."))
    return u.replace(/^file:\/\//, "").replace(/\/$/, "")
  }

  function currentEntry() {
    var config = root.bar && root.bar.shell ? root.bar.shell.shellConfig : null
    var layout = config && config.bar ? config.bar.layout : null
    var sections = ["left", "center", "right"]
    for (var s = 0; layout && s < sections.length; s++) {
      var entries = layout[sections[s]] || []
      for (var i = 0; i < entries.length; i++) {
        if (entries[i] && String(entries[i].id) === root.moduleName)
          return entries[i]
      }
    }
    return root.settings || {}
  }

  function persistSetting(key, value) {
    var live = currentEntry()
    var entry = { id: root.moduleName }
    for (var k in live)
      if (k !== "id")
        entry[k] = live[k]
    entry[key] = value
    root.settings = entry
    if (root.bar && root.bar.shell && typeof root.bar.shell.updateEntryInline === "function")
      root.bar.shell.updateEntryInline(root.moduleName, entry)
  }

  function applySample(raw) {
    var next = Model.parseSample(raw)
    root.sample = next
    root.cpuHistory = Model.pushHistory(root.cpuHistory, next.cpu.percent, 30)
    root.cpuTempHistory = Model.pushHistory(root.cpuTempHistory, next.cpuTemp.packageC, 30)
    root.ramHistory = Model.pushHistory(root.ramHistory, next.ram.percent, 30)
    if (next.gpu) {
      root.gpuHistory = Model.pushHistory(root.gpuHistory, next.gpu.percent, 30)
      root.gpuTempHistory = Model.pushHistory(root.gpuTempHistory, next.gpu.tempC, 30)
    }
  }

  function openDetail(metric) {
    root.settingsVisible = false
    root.detailMetric = metric
    root.detailVisible = true
  }

  function openSettings() {
    root.detailVisible = false
    root.settingsVisible = true
  }

  function close() {
    root.detailVisible = false
    root.settingsVisible = false
  }

  function open() {
    openDetail("cpu")
  }

  function toggle() {
    if (opened)
      close()
    else
      openDetail("cpu")
  }

  readonly property bool popoutSwitchClosing: false
  function closeForPopoutSwitch() { close() }

  implicitWidth: Math.max(Style.bar.statusSlot, row.implicitWidth + Style.space(12))
  implicitHeight: barSize

  Process {
    id: probe
    command: ["python3", root.pluginDir() + "/scripts/probe"]
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applySample(text)
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      if (!probe.running)
        probe.running = true
    }
  }

  DetailPanel {
    id: detailPanel
    anchorItem: hit
    owner: root
    bar: root.bar
    open: root.detailVisible
    focusMetric: root.detailMetric
    sample: root.sample
    onCloseRequested: root.detailVisible = false
  }

  SettingsPanel {
    id: settingsPanel
    anchorItem: hit
    owner: root
    bar: root.bar
    open: root.settingsVisible
    settings: root.settings
    onCloseRequested: root.settingsVisible = false
    onSettingChanged: function(key, value) {
      root.persistSetting(key, value)
    }
  }

  Item {
    id: hit
    anchors.fill: parent

    Row {
      id: row
      anchors.centerIn: parent
      spacing: Style.space(10)

      MetricChip {
        visible: root.showCpu
        iconText: ""
        valueText: Model.formatPercent(root.sample.cpu.percent)
        history: root.cpuHistory
        showGraph: root.showCpuGraph
        hot: root.sample.cpu.percent > root.cpuWarnPercent
        normalColor: root.normalFg
        hotColor: root.hotFg
        fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
        onClicked: root.openDetail("cpu")
        onRightClicked: root.openSettings()
      }

      MetricChip {
        visible: root.showCpuTemp
        iconText: ""
        valueText: Model.formatTemp(root.sample.cpuTemp.packageC)
        history: root.cpuTempHistory
        historyMax: Model.historyMax(root.cpuTempHistory, 100)
        showGraph: root.showCpuTempGraph
        hot: root.sample.cpuTemp.packageC > root.cpuTempWarnC
        normalColor: root.normalFg
        hotColor: root.hotFg
        fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
        onClicked: root.openDetail("cpuTemp")
        onRightClicked: root.openSettings()
      }

      MetricChip {
        visible: root.showRam
        iconText: ""
        valueText: Model.formatRam(root.sample.ram)
        history: root.ramHistory
        showGraph: root.showRamGraph
        hot: root.sample.ram.percent > root.ramWarnPercent
        normalColor: root.normalFg
        hotColor: root.hotFg
        fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
        onClicked: root.openDetail("ram")
        onRightClicked: root.openSettings()
      }

      MetricChip {
        visible: root.showGpu
        iconText: "󰾲"
        valueText: root.sample.gpu ? Model.formatPercent(root.sample.gpu.percent) : "n/a"
        history: root.gpuHistory
        showGraph: root.showGpuGraph
        hot: root.sample.gpu && root.sample.gpu.percent > root.gpuWarnPercent
        normalColor: root.normalFg
        hotColor: root.hotFg
        fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
        onClicked: root.openDetail("gpu")
        onRightClicked: root.openSettings()
      }

      MetricChip {
        visible: root.showGpuTemp
        iconText: "󰔏"
        valueText: root.sample.gpu ? Model.formatTemp(root.sample.gpu.tempC) : "n/a"
        history: root.gpuTempHistory
        historyMax: Model.historyMax(root.gpuTempHistory, 100)
        showGraph: root.showGpuTempGraph
        hot: root.sample.gpu && root.sample.gpu.tempC > root.gpuTempWarnC
        normalColor: root.normalFg
        hotColor: root.hotFg
        fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
        onClicked: root.openDetail("gpuTemp")
        onRightClicked: root.openSettings()
      }
    }
  }
}
