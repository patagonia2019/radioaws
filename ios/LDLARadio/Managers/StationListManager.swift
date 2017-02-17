//
//  StationListManager.swift
//  LDLARadio
//
//  Created by Javier Fuchs on 1/6/17.
//  Copyright © 2017 Mobile Patagonia. All rights reserved.
//

import Foundation
import AVFoundation
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import JFCore

class StationListManager: NSObject {
    // MARK: Properties
    
    /// A singleton instance of StationListManager.
    static let sharedManager = StationListManager()
    
    /// Notification for when download progress has changed.
    static let didLoadNotification = NSNotification.Name(rawValue: "StationListManagerDidLoadNotification")

    static let errorNotification = NSNotification.Name(rawValue: "StationListManagerErrorNotification")

    /// The internal array of Station structs.
    private var stations = [Station]()
    
    // MARK: Initialization
    
    override private init() {
        super.init()
        
        /*
         Do not setup the StationListManager.assets until StationPersistenceManager has
         finished restoring.  This prevents race conditions where the `StationListManager`
         creates a list of `Station`s that doesn't reuse already existing `AVURLAssets`
         from existng `AVAssetDownloadTasks.
         */
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleStationPersistenceManagerDidRestoreStateNotification(_:)), name: StationPersistenceManagerDidRestoreStateNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: StationPersistenceManagerDidRestoreStateNotification, object: nil)
    }
    
    // MARK: Station access
    
    /// Returns the number of Stations.
    func numberOfStations() -> Int {
        return stations.count
    }
    
    /// Returns an Stream for a given IndexPath.
    func station(at index: Int) -> Station {
        return stations[index]
    }

    /// Returns an Station for a given station id.
    func station(by id: Int?) -> Station? {
        for station in stations {
            if station.id == id {
                return station
            }
        }
        return nil
    }
    
    func handleStationPersistenceManagerDidRestoreStateNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            guard let server = UserDefaults.standard.string(forKey: "server_url") else {
                return
            }
            let stationsJsonUrl = server + "/stations.json"

            Alamofire.request(stationsJsonUrl, method:.get).validate().responseArray { (response: DataResponse<[Station]>) in
                if let result = response.result.value {
                    for entry in result {
                        // Get the Station name from the dictionary
                        self.stations.append(entry)
                    }
                    NotificationCenter.default.post(name: StationListManager.didLoadNotification, object: self)
                }
                else if let error = response.result.error {
                    let myerror = JFError(code: 101,
                                          desc: "failed to get appId=\(1) userId=\(1) locationId=\(1)",
                        reason: "something get wrong on request \(stationsJsonUrl)", suggestion: "\(#file):\(#line):\(#column):\(#function)",
                        underError: error as NSError?)
                    NotificationCenter.default.post(name: StationListManager.errorNotification, object: self)
                }
            }
        }
    }
}
