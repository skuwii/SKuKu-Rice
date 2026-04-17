import QtQuick 2.15
import QtQuick.Controls 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#0e0f11"

    property string currentUser: userModel.lastUser

    // Subtle azure glow at bottom
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.6
        height: parent.height * 0.4
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: "#082040" }
        }
        opacity: 0.3
    }

    Column {
        anchors.centerIn: parent
        spacing: 20

        // S mark
        Text {
            text: "S"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 72
            font.bold: true
            color: "#2980d4"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Username
        Text {
            text: currentUser
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 16
            font.bold: true
            color: "#c8ccd4"
            anchors.horizontalCenter: parent.horizontalCenter
            letterSpacing: 2
        }

        // Spacer
        Item { width: 1; height: 8 }

        // Password field
        Rectangle {
            width: 280
            height: 40
            color: "#1c1e21"
            border.color: passwordField.activeFocus ? "#2980d4" : "#3a3e46"
            border.width: 1
            radius: 6
            anchors.horizontalCenter: parent.horizontalCenter

            TextInput {
                id: passwordField
                anchors.fill: parent
                anchors.margins: 12
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
                color: "#c8ccd4"
                echoMode: TextInput.Password
                passwordCharacter: "●"
                focus: true

                Keys.onReturnPressed: {
                    sddm.login(currentUser, passwordField.text, sessionModel.lastIndex)
                }

                Text {
                    text: "enter password"
                    font: parent.font
                    color: "#4a4e56"
                    visible: !parent.text && !parent.activeFocus
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // Error message
        Text {
            id: errorMessage
            text: ""
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 10
            color: "#c0392b"
            anchors.horizontalCenter: parent.horizontalCenter
            letterSpacing: 1
        }

        // Hint
        Text {
            text: "ENTER PASSWORD"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 9
            color: "#4a4e56"
            anchors.horizontalCenter: parent.horizontalCenter
            letterSpacing: 3
        }
    }

    // Clock — bottom right
    Text {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 20
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 11
        color: "#4a4e56"
        text: Qt.formatDateTime(new Date(), "HH:mm · ddd")

        Timer {
            interval: 30000
            running: true
            repeat: true
            onTriggered: parent.text = Qt.formatDateTime(new Date(), "HH:mm · ddd")
        }
    }

    // STR version — bottom left
    Text {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 20
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 9
        color: "#4a4e56"
        text: "STR TERMINAL v3.0"
        letterSpacing: 2
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            errorMessage.text = "[ AUTH FAILED ]"
            passwordField.text = ""
        }
        function onLoginSucceeded() {
            errorMessage.text = ""
        }
    }
}
