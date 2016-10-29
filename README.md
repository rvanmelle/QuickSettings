# SwiftSettings
Build Lightweight In-app Settings screen quickly and easily

```swift
enum Test : String {
    case Lady
    case Tramp
}

let o = EnumSettingsOptions<Test>(defaultValue:.Lady)

let settings = [
    Setting.Group(title:"General", children:[
        Setting.Toggle(label:"Foo", id:"general.foo", default:true),
        Setting.Toggle(label:"Bar", id:"general.bar", default:false),
        Setting.Select(label:"Bar2", id:"general.bar2", options:o),
        Setting.Text(label:"Baz", id:"general.baz", default:"Saskatoon"),
    ]),
    Setting.Group(title:"Extra", children:[
        Setting.Toggle(label:"Foo", id:"extra.foo", default:false),
        Setting.Toggle(label:"Bar", id:"extra.bar", default:true),
        Setting.Text(label:"Baz", id:"extra.baz", default:"Tom"),
    ])
]

class TheDelegate : SettingsViewControllerDelegate {
    func settingsViewController(vc: SettingsViewController, didUpdateSetting id: String) {
        print("Update: \(id)")
    }
}

var theDelegate = TheDelegate()
var ctrl = SettingsViewController(settings:settings, delegate:theDelegate)

```

![Alt text](/screenshots/example1.png?raw=true "Example 1")
