//
//  RNAStation+.swift
//  LDLARadio
//
//  Created by fox on 23/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Foundation
import CoreData
import JFCore

extension RNAStation {
    
    /// placeholder for thumbnails in streams
    static let placeholderImageName: String = "RNA-256x256bb"

    /// Fetch an instance using the id
    static func by(id: String) -> RNAStation? {
        guard let context = RestApi.instance.context else { fatalError() }
        let req = NSFetchRequest<RNAStation>(entityName: "RNAStation")
        req.predicate = NSPredicate(format: "id = %@", id)
        let station = try? context.fetch(req).first
        return station
    }
    
    /// Fetch all the instances of the entity from DB
    static func all() -> [RNAStation]? {
        guard let context = RestApi.instance.context else { fatalError() }
        let req = NSFetchRequest<RNAStation>(entityName: "RNAStation")
        req.sortDescriptors = [NSSortDescriptor.init(key: "lastName", ascending: true)]
        let array = try? context.fetch(req)
        return array
    }
    
    /// Remove all the instances of the entity from DB
    static func clean() {
        guard let context = RestApi.instance.context else {
            fatalError("fatal: no core data context manager")
        }
        let req = NSFetchRequest<RNAStation>(entityName: "RNAStation")
        req.includesPropertyValues = false
        if let array = try? context.fetch(req as! NSFetchRequest<NSFetchRequestResult>) as? [NSManagedObject] {
            for obj in array {
                context.delete(obj)
            }
        }
    }
    
}
