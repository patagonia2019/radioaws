//
//  RNACurrentProgram+.swift
//  LDLARadio
//
//  Created by fox on 23/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreData
import JFCore

extension RNACurrentProgram {
    
    /// Fetch all the instances of the entity from DB
    static func all() -> [RNACurrentProgram]? {
        guard let context = RestApi.instance.context else { fatalError() }
        let req = NSFetchRequest<RNACurrentProgram>(entityName: "RNACurrentProgram")
        req.sortDescriptors = [NSSortDescriptor.init(key: "name", ascending: true)]
        let array = try? context.fetch(req)
        return array
    }
    
    /// Remove the current instance of the entity from DB
    func remove() {
        guard let context = RestApi.instance.context else {
            fatalError("fatal: no core data context manager")
        }
        context.delete(self)
    }
    
    
    /// Remove all the instances of the entity from DB
    static func clean() {
        guard let context = RestApi.instance.context else {
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
