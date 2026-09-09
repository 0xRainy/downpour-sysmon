import QtQuick
import qs.Commons

Item {
  id: root
  property string iconText: ""
  property string valueText: ""
  property var history: []
  property real historyMax: 100
  property bool showGraph: true
  property bool hot: false
  property color normalColor: Color.foreground
  property color hotColor: Color.urgent
  property string fontFamily: Style.font.family

  signal clicked()
  signal rightClicked()

  readonly property color fg: root.hot ? root.hotColor : root.normalColor

  implicitWidth: row.implicitWidth
  implicitHeight: row.implicitHeight

  Row {
    id: row
    spacing: Style.space(5)

    Text {
      text: root.iconText
      color: root.fg
      font.family: root.fontFamily
      font.pixelSize: Style.font.body
      anchors.verticalCenter: parent.verticalCenter
    }

    Text {
      text: root.valueText
      color: root.fg
      font.family: root.fontFamily
      font.pixelSize: Style.font.body
      anchors.verticalCenter: parent.verticalCenter
    }

    MiniSpark {
      visible: root.showGraph
      width: visible ? Style.space(40) : 0
      height: Math.max(10, Style.space(14))
      anchors.verticalCenter: parent.verticalCenter
      values: root.history
      maxValue: root.historyMax
      stroke: root.fg
      fill: Qt.rgba(root.fg.r, root.fg.g, root.fg.b, 0.2)
    }
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor
    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton)
        root.rightClicked()
      else
        root.clicked()
    }
  }
}
