//
//  AppDelegate.swift
//  SettingsExample
//
//  Created by Reid van Melle on 2016-10-30.
//  Copyright © 2016 Reid van Melle. All rights reserved.
//

import UIKit
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


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let vc = SettingsViewController(settings:settings, delegate:self)
        vc.title = "Settings Example"
        let nav = UINavigationController(rootViewController: vc)
        window?.rootViewController = nav
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate : SettingsViewControllerDelegate {
    func settingsViewController(vc: SettingsViewController, didUpdateSetting id: String) {
        
    }
}

