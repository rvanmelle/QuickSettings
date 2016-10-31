//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport
import QuickSettings

enum Test : String {
    case Lady
    case Tramp
}

enum Speed : String {
    case Fast
    case Faster
    case Fastest
}

let speedOptions = EnumSettingsOptions<Speed>(defaultValue:.Fastest)
let whoOptions = EnumSettingsOptions<Test>(defaultValue:.Lady)


let settings = [
    Setting.Group(title:"General", children:[
        Setting.Toggle(label:"Foo", id:"general.foo", default:true),
        Setting.Toggle(label:"Bar", id:"general.bar", default:false),
        Setting.Select(label:"Bar2", id:"general.bar2", options:whoOptions),
        Setting.Text(label:"Baz", id:"general.baz", default:"Saskatoon"),
    ]),
    Setting.Select(label:"How fast?", id:"speed", options:speedOptions),
    Setting.Group(title:"Extra", children:[
        Setting.Toggle(label:"Foo", id:"extra.foo", default:false),
        Setting.Toggle(label:"Bar", id:"extra.bar", default:true),
        Setting.Text(label:"Baz", id:"extra.baz", default:"TomTom"),
    ])
]

class TheDelegate : SettingsViewControllerDelegate {
    func settingsViewController(vc: SettingsViewController, didUpdateSetting id: String) {
        print("Update: \(id)")
    }
}

var theDelegate = TheDelegate()

var defaults = UserDefaults.standard
defaults.set("Whhooppeee", forKey: "general.baz")
defaults.set("nice", forKey: "extra.baz")
defaults.set(true, forKey: "extra.foo")
defaults.synchronize()

var testit = defaults.value(forKey: "general.baz")

var ctrl = SettingsViewController(settings:settings, delegate:theDelegate)
let nav = UINavigationController(rootViewController: ctrl)
nav.view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
ctrl.title = "Settings Example"
ctrl.view.frame = nav.view.frame
PlaygroundPage.current.liveView = nav.view

