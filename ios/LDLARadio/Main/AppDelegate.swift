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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {

        // force english
        UserDefaults.standard.setValue(["en"], forKey: "AppleLanguages")

        FirebaseManager.start()

        RestApi.instance.context = CoreDataManager.instance.taskContext
        #if DEBUG
        registerSettingsBundle()
        #endif
        UIApplication.shared.beginReceivingRemoteControlEvents()

        SwiftSpinner.setTitleFont(UIFont.init(name: Commons.font.name, size: Commons.font.size.S))

        changeAppearance()

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        Analytics.start()

    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        Analytics.stop()
        CloudKitManager.instance.sync()
    }

    private func registerSettingsBundle() {
        var appDefaults = [String: AnyObject]()
        appDefaults["server_url"] = RestApi.Constants.Service.ldlaServer as AnyObject?
        UserDefaults.standard.register(defaults: appDefaults)

        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
    }

    private func changeAppearance() {
        let aqua: UIColor = .aqua
        guard let font = UIFont(name: Commons.font.name, size: Commons.font.size.S) else {
            fatalError()
        }
        let attributes = [NSAttributedString.Key.font: font,
                          NSAttributedString.Key.foregroundColor: aqua]
        UINavigationBar.appearance().titleTextAttributes = attributes

        let unselected = [NSAttributedString.Key.font: font,
                          NSAttributedString.Key.foregroundColor: UIColor.steel]

        UITabBarItem.appearance().setTitleTextAttributes(attributes, for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes(unselected, for: .normal)

        let tabBar = UITabBar.appearance()
        tabBar.isTranslucent = true
        tabBar.tintColor = aqua
        tabBar.barTintColor = UIColor.turquoise

        let tableView = UITableView.appearance()
        tableView.backgroundColor = UIColor.mercury

        let cell = UITableViewCell.appearance()
        cell.backgroundColor = UIColor.mercury
    }

    @objc func defaultsChanged() {
        userDefault = UserDefaults.standard
    }

}

