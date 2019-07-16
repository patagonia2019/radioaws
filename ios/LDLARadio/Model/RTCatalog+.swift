//
//  RTCatalog+.swift
//  LDLARadio
//
//  Created by fox on 13/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Foundation
import CoreData
import JFCore

extension RTCatalog {
    func descript() -> String {
        var str = [String]()
        if let title = title { str.append(title) }
        if let text = text { str.append(text) }
        if let url = url { str.append(url) }
        if let key = key { str.append(key) }
        return str.joined(separator: ", ")
    }
    
    static func clean() {
        guard let context = CoreDataManager.instance.taskContext else {
            fatalError("fatal: no core data context manager")
        }
        let req = NSFetchRequest<RTCatalog>(entityName: "RTCatalog")
        req.includesPropertyValues = false
        if let array = try? context.fetch(req as! NSFetchRequest<NSFetchRequestResult>) as? [NSManagedObject] {
            for obj in array {
                context.delete(obj)
            }
        }
    }
    
    func remove() {
        guard let context = CoreDataManager.instance.taskContext else {
            fatalError("fatal: no core data context manager")
        }
        let req = NSFetchRequest<RTCatalog>(entityName: "RTCatalog")
        if let title = title {
            req.predicate = NSPredicate(format: "title = %@", title)
        }
        else if let text = text {
            req.predicate = NSPredicate(format: "text = %@", text)
        }
        else {
            return
        }
        req.includesPropertyValues = false
        if let array = try? context.fetch(req as! NSFetchRequest<NSFetchRequestResult>) as? [NSManagedObject] {
            for obj in array {
                context.delete(obj)
            }
        }
    }
    
    
    func isAudio() -> Bool {
        return type == "audio"
    }
    
    func isLink() -> Bool {
        return type == nil || type == "link"
    }
    
}
