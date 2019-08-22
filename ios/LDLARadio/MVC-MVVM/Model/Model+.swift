//
//  Model+.swift
//  LDLARadio
//
//  Created by fox on 27/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import AVFoundation
import CoreData

extension Model {
    
    /// Update the `updatedAt` field in the entity when the model is created
    override public func awakeFromInsert() {
        setPrimitiveValue(Date(), forKey: "updatedAt")
    }
    
    static func entityName() -> String? {
        return NSStringFromClass(self).components(separatedBy: ".").last
    }
    
    func parseField(field: Any?) -> String? {
        if let str = field as? String {
            return str
        }
        else if let num = field as? Int {
            return "\(num)"
        }
        else if let num = field as? Float {
            return "\(num)"
        }
        else if let num = field as? Double {
            return "\(num)"
        }
        else if let array = field as? [String] {
            return array.joined(separator: ", ")
        }
        return nil
    }
    
    /// Fetch the most recent updatedAt date
    static func lastUpdated() -> Date? {
        guard let name = entityName() else { return nil }
        guard let context = RestApi.instance.context else { fatalError() }
        let req = NSFetchRequest<Model>(entityName: name)
        req.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        return try? context.fetch(req).first?.updatedAt
    }

    /// Function to obtain all the streams sorted by station.name
    static func all(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [NSManagedObject]? {
        guard let name = entityName() else { return nil }
        guard let context = RestApi.instance.context else { fatalError() }
        let req = NSFetchRequest<NSManagedObject>(entityName: name)
        if let predicate = predicate {
            req.predicate = predicate
        }
        if let sortDescriptors = sortDescriptors {
            req.sortDescriptors = sortDescriptors
        }
        let array = try? context.fetch(req)
        return array
    }
    
    /// Remove all the instances of the entity
    static func clean() {
        guard let name = entityName() else { return }
        guard let context = RestApi.instance.context else { fatalError() }
        let req = NSFetchRequest<NSManagedObject>(entityName: name)
        req.includesPropertyValues = false
        if let array = try? context.fetch(req as! NSFetchRequest<NSFetchRequestResult>) as? [NSManagedObject] {
            for obj in array {
                context.delete(obj)
            }
        }
    }
    
    /// Remove current instance of the entity
    @objc func remove() {
        guard let context = RestApi.instance.context else { fatalError() }
        context.delete(self)
    }
    
}

