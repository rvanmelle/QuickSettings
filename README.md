[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# QuickSettings

The goal of this project is to build lightweight in-app settings screen quickly and easily. It is written in Swift3. Settings are persisted via UserDefaults.standard.

## Disclaimers

This is a work in progress and should not be used in production. If you find this project useful or find it is missing a critical feature for your usage, please let me know and I'll do my best to add/improve based on your requests. 

If you want some advanced, highly customizable, with validation, etc. you should use one of the many incredible open-source form options such as Eureka.

## Installation

**Will be in Carthage**

Currently, you will need to install this manually. There is a framework definition SettingsExample workspace that shows how to use it.

## ToDo

* text editing either via editable cells or alertview (support email, password, url, etc.)
* stepper for integer values
* slider for float values
* inline group selection
* section footers
* custom UserDefaults

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
    Setting.Group(title:"General", children:[
        Setting.Toggle(label:"Foo", id:"general.foo", default:true),
        Setting.Toggle(label:"Bar", id:"general.bar", default:false),
        Setting.Select(label:"Bar2", id:"general.bar2", options:dogOptions),
        Setting.Text(label:"Baz", id:"general.baz", default:"Saskatoon"),
    ]),
    
    Setting.Select(label:"How fast?", id:"speed", options:speedOptions),
    
    Setting.Group(title:"Extra", children:[
        Setting.Toggle(label:"Foo", id:"extra.foo", default:false),
        Setting.Toggle(label:"Bar", id:"extra.bar", default:true),
        Setting.Text(label:"Baz", id:"extra.baz", default:"TomTom"),
    ])
]

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
