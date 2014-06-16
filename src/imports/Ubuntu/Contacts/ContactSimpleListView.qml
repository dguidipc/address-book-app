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

import QtQuick 2.2
import QtContacts 5.0
import Ubuntu.Contacts 0.1
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

import "ContactList.js" as Sections

/*!
    \qmltype ContactSimpleListView
    \inqmlmodule Ubuntu.Contacts 0.1
    \ingroup ubuntu
    \brief The ContactSimpleListView provides a simple contact list view

    The ContactSimpleListView provide a easy way to show the contact list view
    with all default visuals defined by Ubuntu system.

    Example:
    \qml
        import Ubuntu.Contacts 0.1

        ContactSimpleListView {
            anchors.fill: parent
            onContactClicked: console.debug("Contact ID:" + contactId)
        }
    \endqml
*/

MultipleSelectionListView {
    id: contactListView

    /*!
      \qmlproperty bool showAvatar

      This property holds if the contact avatar will appear on the list or not.
      By default this is set to true.
    */
    property bool showAvatar: true

    /*!
      \qmlproperty int titleDetail

      This property holds the contact detail which will be used to display the contact title in the delegate
      By default this is set to ContactDetail.Name.
    */
    property int titleDetail: ContactDetail.DisplayLabel
    /*!
      \qmlproperty list<int> titleFields

      This property holds the list of all fields which will be used to display the contact title in the delegate
      By default this is set to [ Name.FirstName, Name.LastName ]
    */
    property variant titleFields: [ DisplayLabel.Label ]
    /*!
      \qmlproperty list<SortOrder> sortOrders

      This property holds a list of sort orders used by the contacts model.
      \sa SortOrder
    */
    property list<SortOrder> sortOrders : [
        SortOrder {
            detail: ContactDetail.Tag
            field: Tag.Tag
            direction: Qt.AscendingOrder
            blankPolicy: SortOrder.BlanksLast
            caseSensitivity: Qt.CaseInsensitive
        },
        // empty tags will be sorted by display Label
        SortOrder {
            detail: ContactDetail.DisplayLabel
            field: DisplayLabel.Label
            direction: Qt.AscendingOrder
            blankPolicy: SortOrder.BlanksLast
            caseSensitivity: Qt.CaseInsensitive
        }
    ]
    /*!
      \qmlproperty FetchHint fetchHint

      This property holds the fetch hint instance used by the contact model.

      \sa FetchHint
    */
    property var fetchHint : FetchHint {
        detailTypesHint: {
            var hints = [ ContactDetail.Tag,          // sections
                          ContactDetail.PhoneNumber,  // expansion
                          contactListView.titleDetail ]

            if (contactListView.showAvatar) {
                hints.push(ContactDetail.Avatar)
            }
            return hints
        }
    }
    /*!
      \qmlproperty bool multiSelectionEnabled

      This property holds if the multi selection mode is enabled or not
      By default this is set to false
    */
    property bool multiSelectionEnabled: false
    /*!
      \qmlproperty string defaultAvatarImage

      This property holds the default image url to be used when the current contact does
      not contains a photo
    */
    property string defaultAvatarImageUrl: Qt.resolvedUrl("./artwork/contact-default.png")
    /*!
      \qmlproperty bool loading

      This property holds when the model still loading new contacts
    */
    readonly property bool loading: busyIndicator.busy
    /*!
      \qmlproperty int detailToPick

      This property holds the detail type to be picked
    */
    property int detailToPick: 0
    /*!
      \qmlproperty bool showSections

      This property holds if the listview will show or not the section headers
      By default this is set to true
    */
    property bool showSections: true

    /*!
      \qmlproperty string manager

      This property holds the manager uri of the contact backend engine.
      By default this is set to "galera"
    */
    property string manager: (typeof(QTCONTACTS_MANAGER_OVERRIDE) !== "undefined") && (QTCONTACTS_MANAGER_OVERRIDE != "") ? QTCONTACTS_MANAGER_OVERRIDE : "galera"

    /*!
      \qmlproperty Action leftSideAction

      This property holds the available actions when swipe the contact item from left to right
    */
    property Action leftSideAction

    /*!
      \qmlproperty list<Action> rightSideActions

      This property holds the available actions when swipe the contact item from right to left
    */
    property list<Action> rightSideActions

    /*!
      This handler is called when any error occurs in the contact model
    */
    signal error(string message)
    /*!
      This handler is called when any contact detail in the list receives a click
    */
    signal detailClicked(QtObject contact, QtObject detail, string action)
    /*!
      This handler is called when details button on contact delegate is clicked
    */
    signal infoRequested(QtObject contact)
    /*!
      This handler is called when the contact delegate disapear (height === 0) caused by the function call makeDisappear
    */
    signal contactDisappeared(QtObject contact)
    /*!
      Retrieve the contact index inside of the list based on contact id or contact name if the id is empty
    */
    function getIndex(contact)
    {
        var contacts = listModel.contacts
        var contactId = null
        var firstName
        var middleName
        var lastName

        if (contact.contactId !== "qtcontacts:::") {
            contactId = contact.contactId
        } else {
            firstName = contact.name.firstName
            middleName = contact.name.middleName
            lastName = contact.name.lastName
        }

        for (var i = 0, count = contacts.length; i < count; i++) {
            var c = contacts[i]
            if (contactId && (c.contactId === contactId)) {
                return i
            } else if ((c.name.firstName === firstName) &&
                       (c.name.middleName === middleName) &&
                       (c.name.lastName === lastName)) {
                    return i
            }
        }

        return -1
    }

    /*!
      Scroll the list to requested contact if the contact exists in the list
    */
    function positionViewAtContact(contact)
    {
        positionViewAtIndex(getIndex(contact), ListView.Center)
    }

    /*!
      private
      Fetch contact and emit contact clicked signal
    */
    function _fetchContact(index, contact)
    {
        contactFetch.fetchContact(contact.contactId)
    }

    currentIndex: -1
    section {
        property: showSections ? "contact.tag.tag" : ""
        criteria: ViewSection.FirstCharacter
        labelPositioning: ViewSection.InlineLabels
        delegate: Rectangle {
            color: Theme.palette.normal.background
            anchors {
                left: parent.left
                right: parent.right
                margins: units.gu(1)
            }
            height: units.gu(3)
            Label {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                text: section != "" ? section : "#"
                font.pointSize: 76
            }
            ListItem.ThinDivider {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
            }
        }
    }

    onCountChanged: {
        busyIndicator.ping()
        dirtyModel.restart()
    }

    listDelegate: ContactDelegate {
        id: contactDelegate

        // overwrite
        function disappeared()
        {
            contactListView.contactDisappeared(contact)
        }

        width: parent.width
        selected: contactListView.multiSelectionEnabled && contactListView.isSelected(contactDelegate)
        defaultAvatarUrl: contactListView.defaultAvatarImageUrl
        titleDetail: contactListView.titleDetail
        titleFields: contactListView.titleFields

        // ListItemWithActions
        //locked: contactListView.isInSelectionMode || detailsShown
        //triggerActionOnMouseRelease: true
        //leftSideAction: contactListView.leftSideAction
        //rightSideActions: contactListView.rightSideActions

        onDetailClicked: contactListView.detailClicked(contact, detail, action)
        onInfoRequested: contactListView._fetchContact(index, contact)

        Behavior on height {
            id: behaviorOnHeight

            enabled: false
            UbuntuNumberAnimation { }
        }

        // collapse the item before remove it, to avoid crash
        ListView.onRemove: SequentialAnimation {
            ScriptAction {
                script: {
                    if (contactDelegate.state !== "") {
                        contactListView.currentIndex = -1
                    }
                }
            }
        }

        onClicked: {
            if (contactListView.isInSelectionMode) {
                if (!contactListView.selectItem(contactDelegate)) {
                    contactListView.deselectItem(contactDelegate)
                }
                return
            }
            if (ListView.isCurrentItem) {
                contactListView.currentIndex = -1
                return
            // check if we should expand and display the details picker
            } else if (detailToPick !== 0) {
                contactListView.currentIndex = index
                return
            } else if (detailToPick == 0) {
                contactListView.detailClicked(contact, null, "")
            }
        }

        onPressAndHold: {
            if (contactListView.multiSelectionEnabled) {
                contactListView.currentIndex = -1
                contactListView.startSelection()
                contactListView.selectItem(contactDelegate)
            }
        }
        state: ListView.isCurrentItem ? "expanded" : ""
        states: [
            State {
                name: "expanded"
                PropertyChanges {
                    target: contactDelegate
                    clip: true
                    height: contactDelegate.implicitHeight
                    loaderOpacity: 1.0
                    // FIXME: Setting detailsShown to true on expanded state cause the property to change to false and true during the state transition, and that
                    // causes the loader to load twice
                    //detailsShown: true
                }
                PropertyChanges {
                    target: behaviorOnHeight
                    enabled: true
                }
            }
        ]
        transitions: [
            Transition {
                from: "expanded"
                to: ""
                SequentialAnimation {
                    UbuntuNumberAnimation {
                        target: contactDelegate
                        properties: "height, loaderOpacity"
                    }
                    PropertyAction {
                        target: contactDelegate
                        property: "clip"
                    }
                    PropertyAction {
                        target: contactDelegate
                        property: "detailsShown"
                        value: false
                    }
                    PropertyAction {
                        target: contactDelegate
                        property: "ListView.delayRemove"
                        value: false
                    }
                }
            },
            Transition {
                from: ""
                to: "expanded"
                SequentialAnimation {
                    PropertyAction {
                        target: contactDelegate
                        properties: "detailsShown"
                        value: true
                    }
                    PropertyAction {
                        target: contactDelegate
                        properties: "ListView.delayRemove"
                        value: true
                    }
                }
            }
        ]
    }

    ContactFetch {
        id: contactFetch

        model: root.listModel
        onContactFetched: contactListView.infoRequested(contact)
    }

    // This is a workaround to make sure the spinner will disappear if the model is empty
    // FIXME: implement a model property to say if the model still busy or not
    Item {
        id: busyIndicator

        property bool busy: timer.running || priv.currentOperation !== -1

        function ping()
        {
            timer.restart()
        }

        visible: busy
        anchors.fill: parent

        Timer {
            id: timer

            interval: 6000
            running: true
            repeat: false
        }
    }

    Timer {
        id: dirtyModel

        interval: 1000
        running: false
        repeat: false
        onTriggered: Sections.initSectionData(contactListView)
    }

    QtObject {
        id: priv

        property int currentOperation: -1
        property int pendingTargetIndex: 0
        property variant pendingTargetMode: null
    }

    Connections {
        target: Qt.application
        onActiveChanged: {
            if (!Qt.application.active) {
                currentIndex = -1
            }
        }
    }
}
