import QtQuick
import qs.Commons
import qs.Ui

Item {
  id: rowRoot
  property string label: ""
  property string valueText: ""
  property bool showStepper: false
  property bool showToggle: false
  property bool toggleOn: false
  property bool toggleEnabled: true
  property color foreground: Color.foreground
  property string fontFamily: Style.font.family
  property real rowWidth: Style.space(320)
  property real labelOpacity: 0.7
  property int labelPixelSize: Style.font.caption

  signal stepped(int delta)
  signal toggled()

  width: rowWidth
  height: Math.max(Style.space(24), controls.implicitHeight)

  Text {
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    width: parent.width - controls.width - Style.space(12)
    text: rowRoot.label
    color: rowRoot.foreground
    opacity: rowRoot.labelOpacity
    font.family: rowRoot.fontFamily
    font.pixelSize: rowRoot.labelPixelSize
    elide: Text.ElideRight
  }

  Row {
    id: controls
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    spacing: Style.space(6)

    Text {
      visible: rowRoot.showStepper
      text: rowRoot.valueText
      color: rowRoot.foreground
      opacity: 0.85
      font.family: rowRoot.fontFamily
      font.pixelSize: Style.font.caption
      anchors.verticalCenter: parent.verticalCenter
    }

    Rectangle {
      visible: rowRoot.showStepper
      width: 18
      height: 18
      radius: 4
      color: Qt.rgba(1, 1, 1, 0.08)
      Text {
        anchors.centerIn: parent
        text: "−"
        color: rowRoot.foreground
        font.pixelSize: Style.font.caption
      }
      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: rowRoot.stepped(-5)
      }
    }

    Rectangle {
      visible: rowRoot.showStepper
      width: 18
      height: 18
      radius: 4
      color: Qt.rgba(1, 1, 1, 0.08)
      Text {
        anchors.centerIn: parent
        text: "+"
        color: rowRoot.foreground
        font.pixelSize: Style.font.caption
      }
      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: rowRoot.stepped(5)
      }
    }

    ToggleSwitch {
      visible: rowRoot.showToggle
      checked: rowRoot.toggleOn
      interactive: rowRoot.toggleEnabled
      opacity: rowRoot.toggleEnabled ? 1.0 : 0.35
      trackHeight: 14
      cursorRing: false
      foreground: rowRoot.foreground
      onToggled: {
        if (rowRoot.toggleEnabled)
          rowRoot.toggled()
      }
    }
  }
}
