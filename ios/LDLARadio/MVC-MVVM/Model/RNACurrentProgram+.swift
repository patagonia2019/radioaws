//
//  RNACurrentProgram+.swift
//  LDLARadio
//
//  Created by fox on 23/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Foundation
import CoreData
import JFCore

extension RNACurrentProgram {
    
    static func all() -> [RNACurrentProgram]? {
        guard let context = CoreDataManager.instance.taskContext else { fatalError() }
        let req = NSFetchRequest<RNACurrentProgram>(entityName: "RNACurrentProgram")
        req.sortDescriptors = [NSSortDescriptor.init(key: "name", ascending: true)]
        let array = try? context.fetch(req)
        return array
    }
    

    func remove() {
        guard let context = CoreDataManager.instance.taskContext else {
            fatalError("fatal: no core data context manager")
        }
        context.delete(self)
    }
    
    
    static func clean() {
        guard let context = CoreDataManager.instance.taskContext else {
            fatalError("fatal: no core data context manager")
        }
        let req = NSFetchRequest<RNACurrentProgram>(entityName: "RNACurrentProgram")
        req.includesPropertyValues = false
        if let array = try? context.fetch(req as! NSFetchRequest<NSFetchRequestResult>) as? [NSManagedObject] {
            for obj in array {
                context.delete(obj)
            }
        }
    }

}
