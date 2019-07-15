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
    
    func setup(finish: ((_ error: Error?) -> Void)? = nil) {
        RestApi.instance.requestLDLA(usingQuery: "/stations.json", type: Many<Station>.self) { error, _ in
            if let finish = finish {
                finish(error)
                return
            }
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

    private func removeAll() {
        guard let context = CoreDataManager.instance.taskContext else {
            fatalError("fatal: no core data context manager")
        }
        let req = NSFetchRequest<Station>(entityName: "Station")
        req.includesPropertyValues = false
        if let array = try? context.fetch(req as! NSFetchRequest<NSFetchRequestResult>) as? [NSManagedObject] {
            for obj in array {
                context.delete(obj)
            }
        }
    }
    
    private func save() {
        guard let context = CoreDataManager.instance.taskContext else {
            fatalError("fatal: no core data context manager")
        }
        try? context.save()
    }
    
    
    
    private func rollback() {
        guard let context = CoreDataManager.instance.taskContext else {
            fatalError("fatal: no core data context manager")
        }
        context.rollback()
    }
    
    
    func clean() {
        removeAll()
    }
    
    func reset() {
        setup()
    }

}
