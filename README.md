[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# QuickSettings

The goal of this project is to build lightweight in-app settings screen quickly and easily. It is written in Swift3. Settings are persisted via UserDefaults.standard.

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
* action buttons
* unit tests

## Usage

Declare your settings structure. You can use simple string enumerations for option sets. All settings should be given a default value which will be used if UserDefaults.standard does not have a value.

```swift
import QuickSettings

enum Dogs : String {
    case Lady
    case Tramp
}

enum Speed : String {
    case Fast
    case Faster
    case Fastest
}

let settings = [
    QSGroup(title:"General", children:[
        QSToggle(label:"Foo", id:"general.foo", defaultValue:true),
        QSInfo(label: "Bar Info", text: "this is what bar is"),
        QSSelect(label:"Bar2", id:"general.bar2",
                 options:QSEnumSettingsOptions<Dogs>(defaultValue:.Lady)),
        QSText(label:"Baz", id:"general.baz", defaultValue:"Saskatoon"),
    ], footer:"This is a great section for adding lots of random settings that are not really necessary."),
    
    QSText(label:"Info", id:"general.info", defaultValue:"Swing"),
    
    QSSelect(label:"How fast?", id:"speed",
             options:QSEnumSettingsOptions<Speed>(defaultValue:.Fastest)),
    
    QSToggle(label:"Should I?", id:"general.shouldi", defaultValue:true),
    
    QSGroup(title:"Extra", children:[
        QSToggle(label:"Foo", id:"extra.foo", defaultValue:false),
        QSToggle(label:"Bar", id:"extra.bar", defaultValue:true),
        QSText(label:"Baz", id:"extra.baz", defaultValue:"TomTom"),
        
        QSGroup(title:"SubGroup", children:[
            QSToggle(label:"SubFoo", id:"extra.subfoo", defaultValue:false),
            ], footer:"This is a subgroup showing how the definition is recursive")
        
    ])
]
```

If you want to initialize your settings datastore with the declared default values OR reset all of your defaults back to defaults:

```swift
let dataStore = UserDefaults.standard
QSInit(settings: settings, datastore: dataStore)
QSReset(settings: settings, dataStore: dataStore)
```

To use, simply declare a SettingsViewController, typically inside a navigation controller unless no hierarchy is required in your definition.

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let dataStore = UserDefaults.standard
        QSInit(settings: settings, datastore: dataStore)
        let root = QSGroupSetting(title:"Settings Example", children:settings, footer:"These are all of the settings at the top level")
        let vc = QSSettingsViewController(root: root, delegate: self, dataStore: dataStore)
        let nav = UINavigationController(rootViewController: vc)
        window?.rootViewController = nav
        
        return true
    }
```

To be notified of changes:

```swift
extension AppDelegate : QSSettingsViewControllerDelegate {
    func settingsViewController(vc: QSSettingsViewController, didUpdateSetting id: String) {
        
    }
}
```

![Alt text](/screenshots/example1.png?raw=true "Example 1" | width=300)
![Alt text](/screenshots/example2.png?raw=true "Example 1" | width=300)
![Alt text](/screenshots/example3.png?raw=true "Keyboards" | width=300)

## Using a Custom Data Store

You can pass in any datastore that conforms to the QSSettingsDataSource protocol:

```swift
public protocol QSSettingsDataSource {
    
    func bool(forKey:String) -> Bool
    func float(forKey:String) -> Float
    func integer(forKey:String) -> Int
    func string(forKey:String) -> String?
    func hasValue(forKey:String) -> Bool
    
    func set(_ value:Bool, forKey:String)
    func set(_ value:Float, forKey:String)
    func set(_ value:Any?, forKey:String)
}
```
