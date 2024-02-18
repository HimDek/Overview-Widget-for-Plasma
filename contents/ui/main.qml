/*
    SPDX-FileCopyrightText: 2023 Himprakash Deka <himprakashd@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQml 2.15
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PC3
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: main

    readonly property bool inPanel: [
        PlasmaCore.Types.TopEdge,
        PlasmaCore.Types.RightEdge,
        PlasmaCore.Types.BottomEdge,
        PlasmaCore.Types.LeftEdge,
    ].includes(Plasmoid.location)
    
    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical

    // Plasma5Support.DataSource {
    //     id: executable
    //     engine: "executable"
    //     connectedSources: []
    //     onNewData: function(source, data) {
    //         disconnectSource(source)
    //     }

    //     function exec(cmd) {
    //         executable.connectSource(cmd)
    //     }
    // }

    Plasmoid.icon: plasmoid.configuration.icon

    preferredRepresentation: compactRepresentation
    fullRepresentation: null
    compactRepresentation: MouseArea {
        id: compactmain

        readonly property bool tooSmall: Plasmoid.formFactor === PlasmaCore.Types.Horizontal && Math.round(2 * (compactmain.height / 5)) <= Kirigami.Theme.smallFont.pixelSize

        readonly property bool shouldHaveIcon: Plasmoid.formFactor === PlasmaCore.Types.Vertical || Plasmoid.configuration.icon !== ""
        readonly property bool shouldHaveLabel: Plasmoid.formFactor !== PlasmaCore.Types.Vertical && Plasmoid.configuration.menuLabel !== ""

        readonly property int iconSize: 48

        readonly property var sizing: {
            const displayedIcon = buttonIcon.valid ? buttonIcon : buttonIconFallback;

            let impWidth = 0;
            if (shouldHaveIcon) {
                impWidth += displayedIcon.width;
            }
            if (shouldHaveLabel) {
                impWidth += labelTextField.contentWidth + labelTextField.Layout.leftMargin + labelTextField.Layout.rightMargin;
            }
            const impHeight = Math.max(iconSize, displayedIcon.height);

            // at least square, but can be wider/taller
            if (main.inPanel) {
                if (main.vertical) {
                    return {
                        minimumWidth: -1,
                        maximumWidth: iconSize,
                        minimumHeight: impHeight,
                        maximumHeight: impHeight,
                    };
                } else { // horizontal
                    return {
                        minimumWidth: impWidth,
                        maximumWidth: impWidth,
                        minimumHeight: -1,
                        maximumHeight: iconSize,
                    };
                }
            } else {
                return {
                    minimumWidth: impWidth,
                    maximumWidth: -1,
                    minimumHeight: Kirigami.Units.iconSizes.small,
                    maximumHeight: -1,
                };
            }
        }

        implicitWidth: iconSize
        implicitHeight: iconSize

        Layout.minimumWidth: sizing.minimumWidth
        Layout.maximumWidth: sizing.maximumWidth
        Layout.minimumHeight: sizing.minimumHeight
        Layout.maximumHeight: sizing.maximumHeight

        hoverEnabled: true

        onPressed: {
            executable.exec(Plasmoid.configuration.command)
        }
        onClicked: {
            executable.exec(Plasmoid.configuration.command)
        }

        RowLayout {
            id: iconLabelRow
            anchors.fill: parent
            spacing: 0

            Kirigami.Icon {
                id: buttonIcon

                Layout.fillWidth: main.vertical
                Layout.fillHeight: !main.vertical
                Layout.preferredWidth: main.vertical ? -1 : height / (implicitHeight / implicitWidth)
                Layout.preferredHeight: !main.vertical ? -1 : width * (implicitHeight / implicitWidth)
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                source: Tools.iconOrDefault(Plasmoid.formFactor, Plasmoid.configuration.icon)
                active: compactmain.containsMouse || compactDragArea.containsDrag
                roundToIconSize: implicitHeight === implicitWidth
                visible: valid
            }

            Kirigami.Icon {
                id: buttonIconFallback
                // fallback is assumed to be square
                Layout.fillWidth: main.vertical
                Layout.fillHeight: !main.vertical
                Layout.preferredWidth: main.vertical ? -1 : height
                Layout.preferredHeight: !main.vertical ? -1 : width
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                source: buttonIcon.valid ? null : "dialog-layers"
                active: compactmain.containsMouse || compactDragArea.containsDrag
                visible: !buttonIcon.valid && Plasmoid.configuration.icon !== ""
            }

            PC3.Label {
                id: labelTextField

                Layout.fillHeight: true
                Layout.leftMargin: Kirigami.Units.smallSpacing
                Layout.rightMargin: Kirigami.Units.smallSpacing

                text: Plasmoid.configuration.menuLabel
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.NoWrap
                fontSizeMode: Text.VerticalFit
                font.pixelSize: compactmain.tooSmall ? Kirigami.Theme.defaultFont.pixelSize : Kirigami.Units.iconSizes.roundedIconSize(Kirigami.Units.gridUnit * 2)
                minimumPointSize: Kirigami.Theme.smallFont.pointSize
                visible: compactmain.shouldHaveLabel
            }
        }
    }
}
