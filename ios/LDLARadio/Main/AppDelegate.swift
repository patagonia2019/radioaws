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

    static var instance: AppDelegate {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        return delegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {

        // force english
        UserDefaults.standard.setValue(["en"], forKey: "AppleLanguages")

        FirebaseManager.start()

        RestApi.instance.context = CoreDataManager.instance.taskContext
        #if DEBUG
        registerSettingsBundle()
        #endif
        UIApplication.shared.beginReceivingRemoteControlEvents()

        SwiftSpinner.setTitleFont(UIFont.init(name: Commons.Font.regular, size: Commons.Font.Size.XS))

        changeAppearance()

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        Analytics.start()

    }

    func applicationWillResignActive(_ application: UIApplication) {
        CloudKitManager.instance.sync(force: true)
        CoreDataManager.instance.save()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        Analytics.stop()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        CloudKitManager.instance.sync(force: true)
    }

    private func registerSettingsBundle() {
        var appDefaults = [String: AnyObject]()
        appDefaults["server_url"] = RestApi.Constants.Service.ldlaServer as AnyObject?
        UserDefaults.standard.register(defaults: appDefaults)

        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
    }

    private func changeAppearance() {
        let defaultColor: UIColor = .midnight
        guard let font = UIFont(name: Commons.Font.regular, size: Commons.Font.Size.XS) else {
            fatalError()
        }
        let attributes = [NSAttributedString.Key.font: font,
                          NSAttributedString.Key.foregroundColor: defaultColor]
        UINavigationBar.appearance().titleTextAttributes = attributes
        
        if let promptClass = NSClassFromString("_UINavigationBarModernPromptView") as? UIAppearanceContainer.Type {
            UILabel.appearance(whenContainedInInstancesOf: [promptClass]).textColor = UIColor.red
        }

        let unselected = [NSAttributedString.Key.font: font,
                          NSAttributedString.Key.foregroundColor: UIColor.steel]

        UITabBarItem.appearance().setTitleTextAttributes(attributes, for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes(unselected, for: .normal)

        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .selected)
        UIBarButtonItem.appearance().setTitleTextAttributes(unselected, for: .normal)

        let tabBar = UITabBar.appearance()
        tabBar.isTranslucent = true
        tabBar.tintColor = defaultColor
        tabBar.barTintColor = .turquoise

        let tableView = UITableView.appearance()
        tableView.backgroundColor = .mercury

        let cell = UITableViewCell.appearance()
        cell.backgroundColor = .mercury

        let toolbar = UIToolbar.appearance()
        toolbar.isTranslucent = true
        toolbar.tintColor = UIColor.black
        toolbar.barTintColor = .turquoise
        toolbar.backgroundColor = .turquoise
    }

    @objc func defaultsChanged() {
        userDefault = UserDefaults.standard
    }

}
