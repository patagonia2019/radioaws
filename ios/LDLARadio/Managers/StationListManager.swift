//
//  StationListManager.swift
//  LDLARadio
//
//  Created by Javier Fuchs on 1/6/17.
//  Copyright © 2017 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreData
import AlamofireCoreData
import JFCore

struct StationListManager {
    // MARK: Properties

    /// A singleton instance of StationListManager.
    static var instance = StationListManager()

    /// Notification for when download progress has changed.
    static let didLoadNotification = NSNotification.Name(rawValue: "StationListManager.didLoadNotification")

    static let errorNotification = NSNotification.Name(rawValue: "StationListManager.errorNotification")

    /// The internal array of Station structs.
    private var stations = [Station]()

    // MARK: Initialization

    init() {
        update(tryRequest: true)
    }

    mutating func update(tryRequest: Bool = false) {
        // try memory
        if stations.count == 0 {
            // Try the database
            stations = Station.all() ?? [Station]()
        }
        // try request
        if tryRequest && stations.count == 0 {
            setup()
        }
    }

    func setup(finish: ((_ error: JFError?) -> Void)? = nil) {
        RestApi.instance.requestLDLA(usingQuery: "/stations.json", type: Many<Station>.self) { error, _ in
            if let finish = finish {
                finish(error)
                return
            }
            guard let error = error else {
                NotificationCenter.default.post(name: StationListManager.didLoadNotification, object: nil)
                return
            }
            NotificationCenter.default.post(name: StationListManager.errorNotification, object: error)
        }
    }

    func clean() {
        Station.clean()
    }

    func reset() {
        setup()
    }

}
