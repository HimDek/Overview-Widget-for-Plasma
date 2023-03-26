/*
    SPDX-FileCopyrightText: 2023 Himprakash Deka <himprakashd@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
 */
import QtQuick 2.6
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.kquickcontrolsaddons 2.0

Item {
    id: root

    property bool inPanel: plasmoid.location === PlasmaCore.Types.TopEdge
        || plasmoid.location === PlasmaCore.Types.RightEdge
        || plasmoid.location === PlasmaCore.Types.BottomEdge
        || plasmoid.location === PlasmaCore.Types.LeftEdge
    property bool vertical: plasmoid.formFactor === PlasmaCore.Types.Vertical


    PlasmaCore.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: disconnectSource(sourceName)

        function exec(cmd) {
            executable.connectSource(cmd)
        }
    }

    Plasmoid.preferredRepresentation: plasmoid.compactRepresentation
    Plasmoid.icon: plasmoid.configuration.icon
    Plasmoid.fullRepresentation: null
    Plasmoid.compactRepresentation: MouseArea {
        id: compactRoot

        implicitWidth: PlasmaCore.Units.iconSizeHints.panel
        implicitHeight: PlasmaCore.Units.iconSizeHints.panel

        Layout.minimumWidth: {
            if (!root.inPanel) {
                return PlasmaCore.Units.iconSizes.small
            }

            if (root.vertical) {
                return -1;
            } else {
                return Math.min(PlasmaCore.Units.iconSizeHints.panel, parent.height) * buttonIcon.aspectRatio;
            }
        }

        Layout.minimumHeight: {
            if (!root.inPanel) {
                return PlasmaCore.Units.iconSizes.small
            }

            if (root.vertical) {
                return Math.min(PlasmaCore.Units.iconSizeHints.panel, parent.width) * buttonIcon.aspectRatio;
            } else {
                return -1;
            }
        }

        Layout.maximumWidth: {
            if (!root.inPanel) {
                return -1;
            }

            if (root.vertical) {
                return PlasmaCore.Units.iconSizeHints.panel;
            } else {
                return Math.min(PlasmaCore.Units.iconSizeHints.panel, parent.height) * buttonIcon.aspectRatio;
            }
        }

        Layout.maximumHeight: {
            if (!root.inPanel) {
                return -1;
            }

            if (root.vertical) {
                return Math.min(PlasmaCore.Units.iconSizeHints.panel, parent.width) * buttonIcon.aspectRatio;
            } else {
                return PlasmaCore.Units.iconSizeHints.panel;
            }
        }
        
        onClicked: {
                runCommand()
            }

        DropArea {
            id: compactDragArea
            anchors.fill: parent
        }

        PlasmaCore.IconItem {
            id: buttonIcon

            readonly property double aspectRatio: (root.vertical ? implicitHeight / implicitWidth
                : implicitWidth / implicitHeight)

            anchors.fill: parent
            source: plasmoid.icon
            active: parent.containsMouse || compactDragArea.containsDrag
            smooth: true
            roundToIconSize: aspectRatio === 1
        }
    }

    function runCommand() {
        executable.exec(plasmoid.configuration.command)
    }
}
