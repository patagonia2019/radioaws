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
    
    /// Function to obtain all the albums sorted by title
    func citiesFetch() -> [City]? {
        guard let context = CoreDataManager.instance.taskContext else { fatalError() }
        let req = NSFetchRequest<City>(entityName: "City")
        req.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let array = try? context.fetch(req)
        return array
    }

    func setup(finish: ((_ error: Error?) -> Void)? = nil) {
        RestApi.instance.requestLDLA(usingQuery: "/cities.json", type: Many<City>.self) { error, _ in
            if let finish = finish {
                finish(error)
                return
            }
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
    
    
    private func removeAll() {
        guard let context = CoreDataManager.instance.taskContext else {
            fatalError("fatal: no core data context manager")
        }
        let req = NSFetchRequest<City>(entityName: "City")
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
