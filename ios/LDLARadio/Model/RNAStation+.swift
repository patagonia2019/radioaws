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
    
    static func all() -> [RNAStation]? {
        guard let context = CoreDataManager.instance.taskContext else { fatalError() }
        let req = NSFetchRequest<RNAStation>(entityName: "RNAStation")
        req.sortDescriptors = [NSSortDescriptor.init(key: "lastName", ascending: true)]
        let array = try? context.fetch(req)
        return array
    }
    
    static func clean() {
        guard let context = CoreDataManager.instance.taskContext else {
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
