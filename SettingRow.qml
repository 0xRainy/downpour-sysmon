import QtQuick
import qs.Commons

Item {
  id: rowRoot
  property string label: ""
  property string valueText: ""
  property bool showStepper: false
  property bool showToggle: false
  property bool toggleOn: false
  property color foreground: Color.foreground
  property string fontFamily: Style.font.family
  property real rowWidth: Style.space(320)

  signal stepped(int delta)
  signal toggled()

  width: rowWidth
  height: Style.space(28)

  Text {
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    text: rowRoot.label
    color: rowRoot.foreground
    font.family: rowRoot.fontFamily
    font.pixelSize: Style.font.bodySmall
  }

  Row {
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    spacing: Style.space(6)

    Text {
      visible: rowRoot.showStepper
      text: rowRoot.valueText
      color: rowRoot.foreground
      font.family: rowRoot.fontFamily
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
        color: rowRoot.foreground
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
        color: rowRoot.foreground
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
        color: rowRoot.foreground
      }
      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: rowRoot.toggled()
      }
    }
  }
}
