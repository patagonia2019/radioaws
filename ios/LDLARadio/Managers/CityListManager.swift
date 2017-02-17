//
//  CityListManager.swift
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

class CityListManager: NSObject {
    // MARK: Properties
    
    /// A singleton instance of CityListManager.
    static let sharedManager = CityListManager()
    
    /// Notification for when download progress has changed.
    static let didLoadNotification = NSNotification.Name(rawValue: "CityListManagerDidLoadNotification")

    static let errorNotification = NSNotification.Name(rawValue: "CityListManagerErrorNotification")

    /// The internal array of City structs.
    private var cities = [City]()
    
    // MARK: Initialization
    
    override private init() {
        super.init()
        
        /*
         Do not setup the CityListManager.assets until CityPersistenceManager has
         finished restoring.  This prevents race conditions where the `CityListManager`
         creates a list of `City`s that doesn't reuse already existing `AVURLAssets`
         from existng `AVAssetDownloadTasks.
         */
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleCityPersistenceManagerDidRestoreStateNotification(_:)), name: CityPersistenceManagerDidRestoreStateNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: CityPersistenceManagerDidRestoreStateNotification, object: nil)
    }
    
    // MARK: City access
    
    /// Returns the number of Citys.
    func numberOfCitys() -> Int {
        return cities.count
    }
    
    /// Returns an City for a given IndexPath.
    func city(by id: Int?) -> City? {
        for city in cities {
            if city.id == id {
                return city
            }
        }
        return nil
    }
    
    func handleCityPersistenceManagerDidRestoreStateNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            guard let server = UserDefaults.standard.string(forKey: "server_url") else {
                return
            }
            let citiesJsonUrl = server + "/cities.json"

            Alamofire.request(citiesJsonUrl, method:.get).validate().responseArray { (response: DataResponse<[City]>) in
                if let result = response.result.value {
                    for entry in result {
                        // Get the City name from the dictionary
                        self.cities.append(entry)
                    }
                    NotificationCenter.default.post(name: CityListManager.didLoadNotification, object: self)
                }
                else if let error = response.result.error {
                    let myerror = JFError(code: 101,
                                          desc: "failed to get appId=\(1) userId=\(1) locationId=\(1)",
                        reason: "something get wrong on request \(citiesJsonUrl)", suggestion: "\(#file):\(#line):\(#column):\(#function)",
                        underError: error as NSError?)
                    NotificationCenter.default.post(name: CityListManager.errorNotification, object: self)
                }
            }
        }
    }
}
