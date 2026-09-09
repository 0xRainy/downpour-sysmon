import QtQuick
import qs.Commons
import qs.Ui
import "Model.js" as Model

KeyboardPanel {
  id: root
  property string focusMetric: "cpu"
  property var sample: Model.emptySample()
  property bool showCpuFreq: false
  property bool showGpuFreq: false

  signal closeRequested()

  function rowsForMetric() {
    if (focusMetric === "cpu")
      return (sample.cpu && sample.cpu.cores) ? sample.cpu.cores : []
    if (focusMetric === "cpuTemp")
      return (sample.cpuTemp && sample.cpuTemp.cores) ? sample.cpuTemp.cores : []
    if (focusMetric === "ram") {
      var ram = sample.ram || {}
      return [{
        label: "Used",
        valueText: Model.formatBytes(ram.usedBytes) + " / " + Model.formatBytes(ram.totalBytes),
        bar: Math.min(1, (Number(ram.percent) || 0) / 100)
      }]
    }
    // GPU usage + temp share one detail popup.
    if (focusMetric === "gpu" || focusMetric === "gpuTemp") {
      var gpu = sample.gpu
      if (!gpu)
        return [{ label: "GPU", valueText: "n/a", bar: 0 }]
      var rows = [{
        label: "Usage",
        valueText: Model.formatPercent(gpu.percent),
        bar: Math.min(1, (Number(gpu.percent) || 0) / 100)
      }, {
        label: "Temp",
        valueText: gpu.tempC === null || gpu.tempC === undefined ? "n/a" : Model.formatTemp(gpu.tempC),
        bar: gpu.tempC === null || gpu.tempC === undefined ? 0 : Math.min(1, (Number(gpu.tempC) || 0) / 100)
      }]
      if (root.showGpuFreq && gpu.freqMHz) {
        rows.push({
          label: "Clock",
          valueText: Model.formatFreq(gpu.freqMHz),
          bar: 0
        })
      }
      if (gpu.usedBytes && gpu.totalBytes) {
        rows.push({
          label: "VRAM",
          valueText: Model.formatBytes(gpu.usedBytes) + " / " + Model.formatBytes(gpu.totalBytes),
          bar: Math.min(1, (Number(gpu.usedBytes) || 0) / Math.max(1, Number(gpu.totalBytes) || 1))
        })
      }
      return rows
    }
    return []
  }

  readonly property string titleText: {
    if (focusMetric === "cpu" || focusMetric === "cpuTemp") {
      var cpu = sample.cpu
      return (cpu && cpu.name) ? String(cpu.name) : "CPU"
    }
    if (focusMetric === "ram") return "RAM  " + Model.formatRam(sample.ram)
    if (focusMetric === "gpu" || focusMetric === "gpuTemp") {
      var gpu = sample.gpu
      if (!gpu) return "GPU"
      return gpu.name ? String(gpu.name) : "GPU"
    }
    return "System"
  }

  readonly property bool showCoreFreq: root.showCpuFreq && (focusMetric === "cpu" || focusMetric === "cpuTemp")
  readonly property real freqColW: showCoreFreq ? Style.space(64) : 0
  readonly property real labelColW: Style.space(72)

  centerOnBar: false
  focusTarget: keyCatcher
  contentWidth: fittedContentWidth(showCoreFreq ? Style.space(340) : Style.space(300))
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
        leftPadding: Style.space(12)
        rightPadding: Style.space(12)
        topPadding: Style.space(10)
        bottomPadding: Style.space(10)

        Text {
          text: root.titleText
          color: root.bar ? root.bar.foreground : Color.foreground
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.body
          font.bold: true
        }

        Repeater {
          model: root.rowsForMetric()

          delegate: Row {
            required property var modelData
            width: bodyCol.width - bodyCol.leftPadding - bodyCol.rightPadding
            spacing: Style.space(8)

            Text {
              visible: root.showCoreFreq
              width: root.freqColW
              text: modelData.freqMHz ? Model.formatFreq(modelData.freqMHz) : ""
              color: root.bar ? root.bar.foreground : Color.foreground
              font.family: root.bar ? root.bar.fontFamily : Style.font.family
              font.pixelSize: Style.font.caption
              opacity: 0.55
              elide: Text.ElideRight
              anchors.verticalCenter: parent.verticalCenter
            }

            Text {
              width: root.labelColW
              text: String(modelData.label || ("Core " + modelData.id))
              color: root.bar ? root.bar.foreground : Color.foreground
              font.family: root.bar ? root.bar.fontFamily : Style.font.family
              font.pixelSize: Style.font.bodySmall
              opacity: 0.85
              elide: Text.ElideRight
            }

            Rectangle {
              width: parent.width - root.freqColW - root.labelColW - Style.space(52)
                   - Style.space(8) * (root.showCoreFreq ? 3 : 2)
              height: Style.space(8)
              radius: 3
              anchors.verticalCenter: parent.verticalCenter
              color: Qt.rgba(1, 1, 1, 0.08)

              Rectangle {
                property real fill: {
                  if (modelData.bar !== undefined)
                    return Number(modelData.bar) || 0
                  if (modelData.percent !== undefined)
                    return Math.min(1, (Number(modelData.percent) || 0) / 100)
                  if (modelData.celsius !== undefined)
                    return Math.min(1, (Number(modelData.celsius) || 0) / 100)
                  return 0
                }
                width: Math.max(0, parent.width * fill)
                height: parent.height
                radius: parent.radius
                color: root.bar ? root.bar.foreground : Color.foreground
                opacity: 0.75
              }
            }

            Text {
              width: Style.space(52)
              horizontalAlignment: Text.AlignRight
              text: {
                if (modelData.valueText)
                  return String(modelData.valueText)
                if (modelData.percent !== undefined)
                  return Math.round(Number(modelData.percent) || 0) + "%"
                if (modelData.celsius !== undefined)
                  return Math.round(Number(modelData.celsius) || 0) + "°"
                return ""
              }
              color: root.bar ? root.bar.foreground : Color.foreground
              font.family: root.bar ? root.bar.fontFamily : Style.font.family
              font.pixelSize: Style.font.bodySmall
            }
          }
        }
      }
    }
  }
}
