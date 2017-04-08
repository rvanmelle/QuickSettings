[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# QuickSettings

The goal of this project is to build lightweight in-app settings screen quickly and easily. It is written in Swift3. Settings can be automatically persisted via UserDefaults.standard or sent to a custom datasource.

## Disclaimers

This is a work in progress and should not be used in production. If you find this project useful or find it is missing a critical feature for your usage, please let me know and I'll do my best to add/improve based on your requests. 

If you want some advanced, highly customizable, with validation, etc. you should use one of the many incredible open-source form options such as Eureka.

This project *will not* generate a proper settings bundle that can be used for your proper app settings.

## Installation

Install via carthage by adding to your Cartfile:

```
github "rvanmelle/QuickSettings"
```

## ToDo

* editable text cells
  * basic formatting (phone numbers etc)
  * some way to validate and show errors
* stepper for integer values
* slider for float values
* inline group selection
* usage from storyboard
* unit tests

## Usage

Declare your settings structure. You can use simple string enumerations for option sets. All settings should be given a default value which will be used if UserDefaults.standard does not have a value.

```swift
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
```

Create your root setting. This will be used to configure the base view controller for your settings hierarchy. At the highest level, the title will be the title for the root settings view controller, and the footer will be the table footer.

```swift
let root = QSGroup(title:"Settings Example", children:settings, footer:"This is a footer")
```

If you want to initialize your settings datastore with the declared default values OR reset all of your defaults back to defaults:

```swift
let dataStore = UserDefaults.standard
root.initialize(datastore: dataStore)
root.reset(settings: settings, dataStore: dataStore)
```

To use, simply declare a QSSettingsViewController, typically inside a navigation controller unless no hierarchy is required in your definition.

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let dataStore = UserDefaults.standard
        let root = QSGroup(title:"Settings Example", children:settings, footer:"These are all of the settings at the top level")
        let vc = QSSettingsViewController(root: root, delegate: self, dataStore: dataStore)
        let nav = UINavigationController(rootViewController: vc)
        window?.rootViewController = nav
        
        return true
    }
```

To be notified of changes:

```swift
extension AppDelegate : QSSettingsViewControllerDelegate {
    func settingsViewController(settingsVc: QSSettingsViewController, didUpdateSetting id: String) {
        
    }
}
```

![Alt text](/screenshots/example1.png?raw=true "Example 1" | width=300)
![Alt text](/screenshots/example2.png?raw=true "Example 1" | width=300)
![Alt text](/screenshots/example3.png?raw=true "Keyboards" | width=300)

## Using a Custom Data Store

You can pass in any datastore that conforms to the QSSettingsDataSource protocol:

```swift
public protocol QSSettingsDataSource: class {

    func hasValue(forKey: String) -> Bool
    func set(_ value: Any?, forKey defaultName: String)
    func value<T>(forKey key: String, type: T.Type) -> T?
}
```
