//
//  AppDelegate.swift
//  LDLARadio
//
//  Created by Javier Fuchs on 1/6/17.
//  Copyright © 2017 Mobile Patagonia. All rights reserved.
//

import UIKit

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
        changeNavigationBarAppearance()
        changeTabBarAppearance()
        changeTableViewAppearance()
        changeToolbarAppearance()
    }
    
    private func changeNavigationBarAppearance() {
        let defaultColor: UIColor = .midnight
        guard let font = UIFont(name: Commons.Font.regular, size: Commons.Font.Size.XS) else {
            fatalError()
        }
        let attributes = [NSAttributedString.Key.font: font,
                          NSAttributedString.Key.foregroundColor: defaultColor]
        UINavigationBar.appearance().titleTextAttributes = attributes
    }

    private func changeToolbarAppearance() {
        let toolbar = UIToolbar.appearance()
        toolbar.isTranslucent = true
        toolbar.tintColor = UIColor.black
        toolbar.barTintColor = .turquoise
        toolbar.backgroundColor = .turquoise
        
        let defaultColor: UIColor = .midnight
        guard let font = UIFont(name: Commons.Font.regular, size: Commons.Font.Size.XS) else {
            fatalError()
        }
        let attributes = [NSAttributedString.Key.font: font,
                          NSAttributedString.Key.foregroundColor: defaultColor]
        
        let unselected = [NSAttributedString.Key.font: font,
                          NSAttributedString.Key.foregroundColor: UIColor.steel]
        
        let barButtonItem = UIBarButtonItem.appearance()
        barButtonItem.setTitleTextAttributes(attributes, for: .selected)
        barButtonItem.setTitleTextAttributes(unselected, for: .normal)
    }
    
    private func changeTableViewAppearance() {
        let tableView = UITableView.appearance()
        tableView.backgroundColor = .mercury

        let cell = UITableViewCell.appearance()
        cell.backgroundColor = .mercury
    }

    private func changeTabBarAppearance() {
        let defaultColor: UIColor = .midnight
        guard let font = UIFont(name: Commons.Font.regular, size: Commons.Font.Size.XXS) else {
            fatalError()
        }
        let attributes = [NSAttributedString.Key.font: font,
                          NSAttributedString.Key.foregroundColor: defaultColor]
        
        let unselected = [NSAttributedString.Key.font: font,
                          NSAttributedString.Key.foregroundColor: UIColor.steel]

        let tabBar = UITabBar.appearance()
        tabBar.tintColor = defaultColor
        tabBar.barTintColor = .turquoise
        tabBar.isTranslucent = true

        if #available(iOS 13.0, *) {
            let tabBarItemApp = UITabBarItemAppearance(style: Commons.isPad() || Commons.isPhoneX() ? .stacked : .compactInline)
            tabBarItemApp.normal.titleTextAttributes = unselected
            tabBarItemApp.selected.titleTextAttributes = attributes
            let tabBarAppearance = UITabBarAppearance(idiom: Commons.isPad() || Commons.isPhoneX() ? .pad : .phone)
            tabBarAppearance.inlineLayoutAppearance = tabBarItemApp
            tabBarAppearance.selectionIndicatorTintColor = defaultColor
            tabBar.standardAppearance = tabBarAppearance
        } else {
            let tabBarItem = UITabBarItem.appearance()
            tabBarItem.setTitleTextAttributes(attributes, for: .selected)
            tabBarItem.setTitleTextAttributes(unselected, for: .normal)
        }
    }

    @objc func defaultsChanged() {
        userDefault = UserDefaults.standard
    }

}

extension UITabBar {
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = Commons.Size.toolbarHeight
        return sizeThatFits
    }
}
