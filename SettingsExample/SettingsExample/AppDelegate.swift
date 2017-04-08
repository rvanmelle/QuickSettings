//
//  AppDelegate.swift
//  SettingsExample
//
//  Created by Reid van Melle on 2016-10-30.
//  Copyright © 2016 Reid van Melle. All rights reserved.
//

import UIKit
import QuickSettings

enum Dogs: String, QSDescriptionEnum {
    case lady
    case tramp

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
        case .fastest: return "Faster than faster which is faster than fast, but *not* blistering."
        default: return nil
        }

    }
}

let settings : [QSSettable] = [
    QSGroup(title:"General", children:[
        QSToggle(label:"Foo", key:"general.foo", defaultValue:true),
        QSInfo(label: "Bar Info", text: "this is what bar is"),
        QSSelect(label:"Bar2", key:"general.bar2",
                 options:QSEnumSettingsOptions<Dogs>(defaultValue:.lady)),
        QSText(label:"Baz", key:"general.baz", defaultValue:"Saskatoon"),
    ], footer:"This is a great section for adding lots of random settings that are not really necessary."),
    
    QSText(label:"Info", key:"general.info", defaultValue:"Swing"),
    
    QSSelect(label:"How fast?", key:"speed",
             options:QSEnumSettingsOptions<Speed>(defaultValue:.fastest)),
    
    QSToggle(label:"Should I?", key:"general.shouldi", defaultValue:true),
    
    QSGroup(title:"Extra", children:[
        QSToggle(label:"Foo", key:"extra.foo", defaultValue:false),
        QSToggle(label:"Bar", key:"extra.bar", defaultValue:true),
        QSText(label:"Baz", key:"extra.baz", defaultValue:"TomTom"),
        
        QSGroup(title:"SubGroup", children:[
            QSToggle(label:"SubFoo", key:"extra.subfoo", defaultValue:false),
            QSGroup(title: "Text Fields", children: [
                QSText(label: "Password", key: "extra.password", defaultValue: nil, type:.password),
                QSText(label: "Email", key: "extra.email", defaultValue: nil, type:.email),
                QSText(label: "Phone", key: "extra.phone", defaultValue: nil, type:.phone),
                QSText(label: "URL", key: "extra.url", defaultValue: nil, type:.url),
                QSText(label: "Decimal", key: "extra.decimal", defaultValue: nil, type:.decimal),
                QSText(label: "Name", key: "extra.name", defaultValue: nil, type:.name),
                QSText(label: "Int", key: "extra.int", defaultValue: nil, type:.int)
            ])
            ], footer:"This is a subgroup showing how the definition is recursive")
    ])
]


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let dataStore = UserDefaults.standard
        let root = QSGroup(title:"Settings Example", children:settings, footer:"Made with a moderate amount of love by a developer who just wants to get stuff done. This library can be used freely without credit.")
        root.initialize(dataStore)
        let vc = QSSettingsViewController(root: root, delegate: self, dataStore: dataStore)
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

extension AppDelegate : QSSettingsViewControllerDelegate {
    func settingsViewController(settingsVc vc: QSSettingsViewController, didUpdateSetting id: String) {
        
    }
}

