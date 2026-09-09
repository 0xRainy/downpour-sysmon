import QtQuick
import qs.Commons
import qs.Ui
import "Model.js" as Model

KeyboardPanel {
  id: root
  property string focusMetric: "cpu"
  property var sample: Model.emptySample()

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
    if (focusMetric === "gpu" || focusMetric === "gpuTemp") {
      var gpu = sample.gpu
      if (!gpu)
        return [{ label: "GPU", valueText: "n/a", bar: 0 }]
      if (focusMetric === "gpu")
        return [{
          label: gpu.name || "GPU",
          valueText: Model.formatPercent(gpu.percent),
          bar: Math.min(1, (Number(gpu.percent) || 0) / 100)
        }]
      return [{
        label: gpu.name || "GPU",
        valueText: Model.formatTemp(gpu.tempC),
        bar: Math.min(1, (Number(gpu.tempC) || 0) / 100)
      }]
    }
    return []
  }

  readonly property string titleText: {
    if (focusMetric === "cpu") return "CPU  " + Model.formatPercent(sample.cpu ? sample.cpu.percent : 0)
    if (focusMetric === "cpuTemp") return "CPU Temp  " + Model.formatTemp(sample.cpuTemp ? sample.cpuTemp.packageC : 0)
    if (focusMetric === "ram") return "RAM  " + Model.formatRam(sample.ram)
    if (focusMetric === "gpu") return "GPU  " + (sample.gpu ? Model.formatPercent(sample.gpu.percent) : "n/a")
    if (focusMetric === "gpuTemp") return "GPU Temp  " + (sample.gpu ? Model.formatTemp(sample.gpu.tempC) : "n/a")
    return "System"
  }

  centerOnBar: false
  focusTarget: keyCatcher
  contentWidth: fittedContentWidth(Style.space(300))
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
              width: Style.space(72)
              text: String(modelData.label || ("Core " + modelData.id))
              color: root.bar ? root.bar.foreground : Color.foreground
              font.family: root.bar ? root.bar.fontFamily : Style.font.family
              font.pixelSize: Style.font.bodySmall
              opacity: 0.85
              elide: Text.ElideRight
            }

            Rectangle {
              width: parent.width - Style.space(72) - Style.space(52) - Style.space(16)
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
