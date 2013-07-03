/*
 * Copyright (C) 2012-2013 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0

FocusScope {
    id: root

    property QtObject contact: null
    property QtObject detail: null
    property bool editable: false
    property bool valid: false

    property Component view
    property Component editor

    function edit() {
        if (detail && !detail.readOnly && editor) {
            state = "edit"
        }
    }

    function save() {
//        if (state == "edit") {
//            //TODO
//            state = "view"
//        }
    }

    states: [
        State {
            name: "view"
            PropertyChanges {
                target: contents
                sourceComponent: view
            }
        },
        State {
            name: "edit"
            PropertyChanges {
                target: contents
                sourceComponent: editor
            }
        }
    ]

    state: "view"
    implicitHeight: contents.item && root.detail ? contents.item.height : 0

    Loader {
        id: contents

        anchors.fill: parent

        Binding {
            target: contents.item
            property: "detail"
            value: root.detail
            when: contents.item != null && contents.item != undefined
        }

        Binding {
            target: contents.item
            property: "contact"
            value: root.contact
            when: contents.item != null && contents.item != undefined
        }
    }
}
