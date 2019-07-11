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
    static let didLoadNotification = NSNotification.Name(rawValue: "CityListManagerDidLoadNotification")

    static let errorNotification = NSNotification.Name(rawValue: "CityListManagerErrorNotification")

    /// The internal array of City structs.
    private var cities = [City]()
    
    // MARK: Initialization
    init() {
        update(tryRequest: true)
    }
    
    mutating func update(tryRequest: Bool = false) {
        // try memory
        if cities.count == 0 {
            // Try the database
            cities = citiesFetch() ?? [City]()
        }
        // try request
        if tryRequest && cities.count == 0 {
            setup()
        }
    }

    
    // MARK: City access
    
    /// Returns the number of Citys.
    func numberOfCitys() -> Int {
        return cities.count
    }
    
    /// Returns an City for a given IndexPath.
    func city(by id: Int16?) -> City? {
        guard let id = id else { return nil }
        for city in cities {
            if city.id == id {
                return city
            }
        }
        return nil
    }
    
    /// Function to obtain all the albums sorted by title
    func citiesFetch() -> [City]? {
        guard let context = CoreDataManager.instance.taskContext else { fatalError() }
        let req = NSFetchRequest<City>(entityName: "City")
        req.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let array = try? context.fetch(req)
        return array
    }

    func setup() {
        RestApi.instance.request(usingQuery: "/cities.json", type: Many<City>.self) { error in
            guard let error = error else {
                NotificationCenter.default.post(name: CityListManager.didLoadNotification, object: nil)
                return
            }
            let jerror = JFError(code: 101,
                                 desc: "failed to get cities.json",
                                 reason: "something get wrong on request cities.json", suggestion: "\(#file):\(#line):\(#column):\(#function)",
                underError: error as NSError?)
            NotificationCenter.default.post(name: CityListManager.errorNotification, object: jerror)
        }
    }

}
