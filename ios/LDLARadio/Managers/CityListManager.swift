//
//  CityListManager.swift
//  LDLARadio
//
//  Created by Javier Fuchs on 1/6/17.
//  Copyright © 2017 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreData
import AlamofireCoreData
import JFCore

struct CityListManager {
    // MARK: Properties

    /// A singleton instance of CityListManager.
    static var instance = CityListManager()

    /// Notification for when download progress has changed.
    static let didLoadNotification = NSNotification.Name(rawValue: "CityListManager.didLoadNotification")

    static let errorNotification = NSNotification.Name(rawValue: "CityListManager.errorNotification")

    /// The internal array of City structs.
    private var cities = [City]()

    // MARK: Initialization
    init() {
        update(tryRequest: true)
    }

    mutating func update(tryRequest: Bool = false) {
        // try memory
        if cities.isEmpty {
            // Try the database
            cities = City.all() ?? [City]()
        }
        // try request
        if tryRequest && cities.isEmpty {
            setup()
        }
    }

    // MARK: City access

    func setup(finish: ((_ error: JFError?) -> Void)? = nil) {
        RestApi.instance.requestLDLA(usingQuery: "/cities.json", type: Many<City>.self) { error, _ in
            if let finish = finish {
                finish(error)
                return
            }
            guard let error = error else {
                NotificationCenter.default.post(name: CityListManager.didLoadNotification, object: nil)
                return
            }
            NotificationCenter.default.post(name: CityListManager.errorNotification, object: error)
        }
    }

    func clean() {
        City.clean()
    }

    func reset() {
        setup()
    }

}
