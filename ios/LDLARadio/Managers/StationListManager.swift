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
    static let didLoadNotification = NSNotification.Name(rawValue: "StationListManagerDidLoadNotification")

    static let errorNotification = NSNotification.Name(rawValue: "StationListManagerErrorNotification")

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
            stations = stationsFetch() ?? [Station]()
        }
        // try request
        if tryRequest && stations.count == 0 {
            setup()
        }
    }


    // MARK: Station access
    
    /// Function to obtain all the albums sorted by title
    func stationsFetch() -> [Station]? {
        guard let context = CoreDataManager.instance.taskContext else { fatalError() }
        let req = NSFetchRequest<Station>(entityName: "Station")
        req.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let array = try? context.fetch(req)
        return array
    }

    /// Returns the number of Stations.
    func numberOfStations() -> Int {
        return stations.count
    }
    
    /// Returns an Stream for a given IndexPath.
    func station(at index: Int) -> Station {
        return stations[index]
    }

    /// Returns an Station for a given station id.
    func station(by id: Int16?) -> Station? {
        guard let context = CoreDataManager.instance.taskContext else { fatalError() }
        let req = NSFetchRequest<Station>(entityName: "Station")
        guard let id = id else { return nil }
        req.predicate = NSPredicate(format: "id = %d", id)
        let array = try? context.fetch(req)
        return array?.first
    }
    
    func setup() {
        RestApi.instance.request(usingQuery: "/stations.json", type: Many<Station>.self) { error in
            guard let error = error else {
                NotificationCenter.default.post(name: StationListManager.didLoadNotification, object: nil)
                return
            }
            let jerror = JFError(code: 101,
                                 desc: "failed to get stations.json",
                                 reason: "something get wrong on request stations.json", suggestion: "\(#file):\(#line):\(#column):\(#function)",
                underError: error as NSError?)
            NotificationCenter.default.post(name: StationListManager.errorNotification, object: jerror)
        }
    }
}
