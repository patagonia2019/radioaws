//
//  RNADial+.swift
//  LDLARadio
//
//  Created by fox on 23/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Foundation
import CoreData
import JFCore

extension RNADial {
    
    /// Update the `updatedAt` field in the entity when the model is created
    override public func awakeFromInsert() {
        setPrimitiveValue(Date(), forKey: "updatedAt")
    }

    /// Fetch all the instances of the entity from DB
    static func all() -> [RNADial]? {
        guard let context = CoreDataManager.instance.taskContext else { fatalError() }
        let req = NSFetchRequest<RNADial>(entityName: "RNADial")
        let array = try? context.fetch(req)
        return array
    }

    /// Fetch the most recent updatedAt date
    static func lastUpdated() -> Date? {
        guard let context = CoreDataManager.instance.taskContext else { fatalError() }
        let req = NSFetchRequest<RNADial>(entityName: "RNADial")
        req.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        return try? context.fetch(req).first?.updatedAt
    }

    /// Remove all the instances of the entity from DB
    static func clean() {
        guard let context = CoreDataManager.instance.taskContext else {
            fatalError("fatal: no core data context manager")
        }
        let req = NSFetchRequest<RNADial>(entityName: "RNADial")
        req.includesPropertyValues = false
        if let array = try? context.fetch(req as! NSFetchRequest<NSFetchRequestResult>) as? [NSManagedObject] {
            for obj in array {
                context.delete(obj)
            }
        }
    }

}
