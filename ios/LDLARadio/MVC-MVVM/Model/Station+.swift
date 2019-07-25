//
//  Station+.swift
//  LDLARadio
//
//  Created by fox on 23/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Foundation
import CoreData
import JFCore

extension Station {
   
    /// Fetch all the instances of the entity from DB
    static func all() -> [Station]? {
        guard let context = CoreDataManager.instance.taskContext else { fatalError() }
        let req = NSFetchRequest<Station>(entityName: "Station")
        req.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let array = try? context.fetch(req)
        return array
    }
    
    /// Remove all the instances of the entity from DB
    static func clean() {
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
}
