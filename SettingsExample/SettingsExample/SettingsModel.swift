//
//  SettingsModel.swift
//  SettingsExample
//
//  Created by Reid van Melle on 2017-04-08.
//  Copyright © 2017 Reid van Melle. All rights reserved.
//

import Foundation
import QuickSettings

enum Dogs: String, QSDescriptionEnum {
    case lady = "Lady"
    case tramp = "Tramp"

    var description: String? {
        switch self {
        case .lady: return "He/she is dignified and proper."
        case .tramp: return "He/she is sassy and engaging."
        }
    }
}

enum Speed: String, QSDescriptionEnum {
    case fast
    case faster
    case fastest
    var description: String? {
        switch self {
        case .fastest: return "A little faster than faster"
        default: return nil
        }

    }
}

let settings: [QSSettable] = [
    QSGroup(title: "General", children: [
        QSToggle(label: "Foo", key: "general.foo", defaultValue: true),
        QSInfo(label: "Bar Info", text: "this is what bar is"),
        QSSelect(label: "Bar2", key: "general.bar2",
                 options: QSEnumSettingsOptions<Dogs>(defaultValue:.lady)),
        QSText(label: "Baz", key: "general.baz", defaultValue: "Saskatoon"),
        ], footer: "This is a great section for adding lots of random settings that are not really necessary."),

    QSText(label: "Info", key: "general.info", defaultValue: "Swing"),

    QSGroup(title: "Actions", footer: nil, childrenCallback: { () -> [QSSettable] in
        let simpleAction = QSAction(title: "Simple Action", actionCallback: {
            print("Simple Action")
        })
        let destructiveAction = QSAction(title: "Reset all data", actionType: QSAction.ActionType.destructive, actionCallback: {
            print("Delete all data")
        })
        return [simpleAction, destructiveAction]
    }),

    QSSelect(label: "How fast?", key: "speed",
             options:QSEnumSettingsOptions<Speed>(defaultValue: .fastest)),

    QSToggle(label: "Should I?", key: "general.shouldi", defaultValue: true),

    QSGroup(title: "Extra", children: [
        QSToggle(label: "Foo", key: "extra.foo", defaultValue: false),
        QSToggle(label: "Bar", key: "extra.bar", defaultValue: true),
        QSText(label: "Baz", key: "extra.baz", defaultValue: "TomTom"),

        QSGroup(title: "SubGroup", children: [
            QSToggle(label: "SubFoo", key: "extra.subfoo", defaultValue: false),
            QSGroup(title: "Text Fields", children: [
                QSText(label: "Password", key: "extra.password", placeholder: "Enter password", type: .password),
                QSText(label: "Email", key: "extra.email", placeholder: "Work email address", type: .email),
                QSText(label: "Phone", key: "extra.phone", defaultValue: nil, type: .phone),
                QSText(label: "URL", key: "extra.url", defaultValue: nil, type: .url),
                QSText(label: "Decimal", key: "extra.decimal", defaultValue: nil, type: .decimal),
                QSText(label: "Name", key: "extra.name", defaultValue: nil, type: .name),
                QSText(label: "Int", key: "extra.int", defaultValue: nil, type: .int)
                ])
            ], footer: "This is a subgroup showing how the definition is recursive")
        ])
]
