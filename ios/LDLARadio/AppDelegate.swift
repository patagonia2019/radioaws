//
//  AppDelegate.swift
//  LDLARadio
//
//  Created by Javier Fuchs on 1/6/17.
//  Copyright © 2017 Mobile Patagonia. All rights reserved.
//

import UIKit
import JFCore
import SwiftSpinner

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var userDefault: UserDefaults?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        registerSettingsBundle()
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        // Restore the state of the application and any running downloads.
        StreamPersistenceManager.sharedManager.restorePersistenceManager()

        SwiftSpinner.setTitleFont(UIFont.init(name: Commons.font.name, size: Commons.font.size))

        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        CoreDataManager.instance.save()
    }
    
    func registerSettingsBundle() {
        var appDefaults = [String:AnyObject]()
        appDefaults["server_url"] = RestApi.Constants.Service.ldlaServer as AnyObject?
        UserDefaults.standard.register(defaults: appDefaults)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    @objc func defaultsChanged() {
        userDefault = UserDefaults.standard
    }
    
}
