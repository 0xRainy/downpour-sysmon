import QtQuick

Item {
  id: root
  property var values: []
  property color stroke: "#ffffff"
  property color fill: Qt.rgba(stroke.r, stroke.g, stroke.b, 0.22)
  property real maxValue: 100

  Canvas {
    id: canvas
    anchors.fill: parent
    antialiasing: true
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      var pts = root.values instanceof Array ? root.values : []
      if (pts.length < 2 || width < 2 || height < 2)
        return
      var maxV = root.maxValue > 0 ? root.maxValue : 100
      var step = width / Math.max(1, pts.length - 1)
      ctx.beginPath()
      for (var i = 0; i < pts.length; i++) {
        var v = Math.max(0, Math.min(maxV, Number(pts[i]) || 0))
        var x = i * step
        var y = height - (v / maxV) * height
        if (i === 0) ctx.moveTo(x, y)
        else ctx.lineTo(x, y)
      }
      ctx.lineTo(width, height)
      ctx.lineTo(0, height)
      ctx.closePath()
      ctx.fillStyle = root.fill
      ctx.fill()
      ctx.beginPath()
      for (var j = 0; j < pts.length; j++) {
        var vv = Math.max(0, Math.min(maxV, Number(pts[j]) || 0))
        var xx = j * step
        var yy = height - (vv / maxV) * height
        if (j === 0) ctx.moveTo(xx, yy)
        else ctx.lineTo(xx, yy)
      }
      ctx.strokeStyle = root.stroke
      ctx.lineWidth = 1.25
      ctx.stroke()
    }
  }

  onValuesChanged: canvas.requestPaint()
  onWidthChanged: canvas.requestPaint()
  onHeightChanged: canvas.requestPaint()
  onStrokeChanged: canvas.requestPaint()
  onFillChanged: canvas.requestPaint()
  onMaxValueChanged: canvas.requestPaint()
}
