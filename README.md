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

* text editing either via editable cells or alertview (support email, password, url, etc.)
* stepper for integer values
* slider for float values
* inline group selection
* section footers
* custom UserDefaults
* usage from storyboard
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

let speedOptions = EnumSettingsOptions<Speed>(defaultValue:.Fastest)
let dogOptions = EnumSettingsOptions<Dogs>(defaultValue:.Lady)

let settings = [
    quickGroup(title:"General", children:[
        quickToggle(label:"Foo", id:"general.foo", defaultValue:true),
        quickToggle(label:"Bar", id:"general.bar", defaultValue:false),
        quickSelect(label:"Bar2", id:"general.bar2", options:dogOptions),
        quickText(label:"Baz", id:"general.baz", defaultValue:"Saskatoon"),
    ]),
    
    quickText(label:"Info", id:"general.info", defaultValue:"Swing"),
    
    quickSelect(label:"How fast?", id:"speed", options:speedOptions),
    
    quickToggle(label:"Should I?", id:"general.shouldi", defaultValue:true),
    
    quickGroup(title:"Extra", children:[
        quickToggle(label:"Foo", id:"extra.foo", defaultValue:false),
        quickToggle(label:"Bar", id:"extra.bar", defaultValue:true),
        quickText(label:"Baz", id:"extra.baz", defaultValue:"TomTom"),
    ])
]

```

If you want to initialize your settings datastore with the declared default values OR reset all of your defaults back to defaults:

```swift
let dataStore = UserDefaults.standard
quickInit(settings: settings, datastore: dataStore)
quickReset(settings: settings, dataStore: dataStore)
```

To use, simply declare a SettingsViewController, typically inside a navigation controller unless no hierarchy is required in your definition.

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let vc = SettingsViewController(settings:settings, delegate:self)
        vc.title = "Settings Example"
        let nav = UINavigationController(rootViewController: vc)
        window?.rootViewController = nav
        
        return true
    }
```

To be notified of changes:

```swift
extension AppDelegate : SettingsViewControllerDelegate {
    func settingsViewController(vc: SettingsViewController, didUpdateSetting id: String) {
        
    }
}
```

![Alt text](/screenshots/example1.png?raw=true "Example 1" | width=300)
