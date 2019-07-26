//
//  City+.swift
//  LDLARadio
//
//  Created by fox on 23/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreData
import JFCore

extension City {
    
    /// Function to obtain all the albums sorted by title
    static func all() -> [City]? {
        guard let context = RestApi.instance.context else { fatalError() }
        let req = NSFetchRequest<City>(entityName: "City")
        req.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let array = try? context.fetch(req)
        return array
    }

    /// Remove all the instances of the entity
    static func clean() {
        guard let context = RestApi.instance.context else {
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
}
