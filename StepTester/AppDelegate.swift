//
//  AppDelegate.swift
//  StepTester
//
//  Created by Jay Tucker on 2/16/18.
//  Copyright © 2018 Imprivata. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        registerDefaultsFromSettingsBundle()
        
        return true
    }
    
    private func registerDefaultsFromSettingsBundle() {
        let settingsUrl = Bundle.main.url(forResource: "Settings", withExtension: "bundle")!.appendingPathComponent("Root.plist")
        let settingsPlist = NSDictionary(contentsOf:settingsUrl)!
        let preferences = settingsPlist["PreferenceSpecifiers"] as! [NSDictionary]
        var defaultsToRegister = Dictionary<String, Any>()
        for preference in preferences {
            guard let key = preference["Key"] as? String else {
                print("key not fount")
                continue
            }
            defaultsToRegister[key] = preference["DefaultValue"]
        }
        UserDefaults.standard.register(defaults: defaultsToRegister)
    }

}

