//
//  FirebaseManager.swift
//  LDLARadio
//
//  Created by fox on 04/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation

class FirebaseManager {

    class func start() {

        FirebaseApp.configure()

        #if os(iOS)
        let selector = #selector(logCustomEventWithName(_:customAttributes:))
        let cl: AnyClass = FirebaseManager.self
        Analytics.configureWithAnalyticsTarget(target: cl, selector: selector)
        #endif
    }

    @objc class func logCustomEventWithName(_ event: String, customAttributes: [String: AnyObject]?) {
        FirebaseAnalytics.Analytics.logEvent(event, parameters: customAttributes)
    }

}
