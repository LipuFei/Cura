// Copyright (c) 2017 Ultimaker B.V.
// Cura is released under the terms of the AGPLv3 or higher.

import QtQuick 2.1
import QtQuick.Controls 1.1
import QtQuick.Dialogs 1.2

import UM 1.2 as UM
import Cura 1.1 as Cura

UM.Dialog
{
    id: base
    title: catalog.i18nc("@title:window", "Discard or Keep changes")

    width: 800
    height: 400
    property var changesModel: Cura.UserChangesModel{ id: userChangesModel}
    onVisibilityChanged:
    {
        if(visible)
        {
            changesModel.forceUpdate()

            discardOrKeepProfileChangesDropDownButton.currentIndex = 0;
            for (var i = 0; i < discardOrKeepProfileChangesDropDownButton.model.count; ++i)
            {
                var code = discardOrKeepProfileChangesDropDownButton.model.get(i).code;
                if (code == UM.Preferences.getValue("cura/choice_on_profile_override"))
                {
                    discardOrKeepProfileChangesDropDownButton.currentIndex = i;
                    break;
                }
            }
        }
    }

    Column
    {
        anchors.fill: parent
        spacing: UM.Theme.getSize("default_margin").width

        UM.I18nCatalog
        {
            id: catalog;
            name: "cura"
        }

        Row
        {
            height: childrenRect.height
            anchors.margins: UM.Theme.getSize("default_margin").width
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: UM.Theme.getSize("default_margin").width

            Label
            {
                text: catalog.i18nc("@text:window", "You have customized some profile settings.\nWould you like to keep or discard those settings?")
                anchors.margins: UM.Theme.getSize("default_margin").width
                font: UM.Theme.getFont("default")
                wrapMode: Text.WordWrap
            }
        }

        TableView
        {
            anchors.margins: UM.Theme.getSize("default_margin").width
            anchors.left: parent.left
            anchors.right: parent.right
            height: base.height - 150
            id: tableView
            Component
            {
                id: labelDelegate
                Label
                {
                    property var extruder_name: userChangesModel.getItem(styleData.row).extruder
                    anchors.left: parent.left
                    anchors.leftMargin: UM.Theme.getSize("default_margin").width
                    font: UM.Theme.getFont("system")
                    text:
                    {
                        var result = styleData.value
                        if (extruder_name != "")
                        {
                            result += " (" + extruder_name + ")"
                        }
                        return result
                    }
                }
            }

            Component
            {
                id: defaultDelegate
                Label
                {
                    text: styleData.value
                    font: UM.Theme.getFont("system")
                    color: UM.Theme.getColor("setting_control_disabled_text")
                }
            }

            TableViewColumn
            {
                role: "label"
                title: catalog.i18nc("@title:column", "Profile settings")
                delegate: labelDelegate
                width: tableView.width * 0.4
            }
            TableViewColumn
            {
                role: "original_value"
                title: catalog.i18nc("@title:column", "Default")
                width: tableView.width * 0.3
                delegate: defaultDelegate
            }
            TableViewColumn
            {
                role: "user_value"
                title: catalog.i18nc("@title:column", "Customized")
                width: tableView.width * 0.3 - 1
            }
            section.property: "category"
            section.delegate: Label
            {
                text: section
                font.bold: true
            }

            model: base.changesModel
        }

        Item
        {
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.margins: UM.Theme.getSize("default_margin").width
            height:childrenRect.height

            ComboBox
            {
                id: discardOrKeepProfileChangesDropDownButton
                width: 300

                model: ListModel
                {
                    id: discardOrKeepProfileListModel

                    Component.onCompleted: {
                        append({ text: catalog.i18nc("@option:discardOrKeep", "Always ask me this"), code: "always_ask" })
                        append({ text: catalog.i18nc("@option:discardOrKeep", "Discard and never ask again"), code: "always_discard" })
                        append({ text: catalog.i18nc("@option:discardOrKeep", "Keep and never ask again"), code: "always_keep" })
                    }
                }

                onActivated: UM.Preferences.setValue("cura/choice_on_profile_override", model.get(index).code)
            }
        }

        Item
        {
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.margins: UM.Theme.getSize("default_margin").width
            height: childrenRect.height

            Button
            {
                id: discardButton
                text: catalog.i18nc("@action:button", "Discard");
                anchors.right: parent.right
                onClicked:
                {
                    Printer.discardOrKeepProfileChangesClosed("discard")
                    base.hide()
                }
                isDefault: true
            }

            Button
            {
                id: keepButton
                text: catalog.i18nc("@action:button", "Keep");
                anchors.right: discardButton.left
                anchors.rightMargin: UM.Theme.getSize("default_margin").width
                onClicked:
                {
                    Printer.discardOrKeepProfileChangesClosed("keep")
                    base.hide()
                }
            }

            Button
            {
                id: createNewProfileButton
                text: catalog.i18nc("@action:button", "Create New Profile");
                anchors.left: parent.left
                action: Cura.Actions.addProfile
                onClicked: base.hide()
            }
        }
    }
}