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
    
    override public func awakeFromInsert() {
        setPrimitiveValue(Date(), forKey: "updatedAt")
    }

    func titleOrText() -> String? {
        return title ?? text
    }
    
    func titleTree() -> String {
        var str = ArraySlice<String>()
        if let t0 = sectionCatalog?.titleTree() {
            str.append(t0 + "> ")
        }
        if let t1 = titleOrText() {
            str.append(t1)
        }
        while str.joined().count > 30 && str.count > 1 {
            _ = str.popFirst()
        }
        return str.joined()
    }
    
    
    func descript() -> String {
        var str = [String]()
        if let title = title { str.append(title) }
        if let url = url { str.append(url) }
        if let key = key { str.append(key) }
        if let sections = sections { str.append("\(sections) sections") }
        if let audios = audios { str.append("\(audios.count) audios") }
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
        context.delete(self)
    }
    
    
    func isOnlyText() -> Bool {
        return type == "text" || (sections?.count == 0 && audios?.count == 0 && title != "Browse")
    }
    
    func isAudio() -> Bool {
        return type == "audio"
    }
    
    func isLink() -> Bool {
        return type == nil || type == "link"
    }
    
    static func all() -> [RTCatalog]? {
        guard let context = CoreDataManager.instance.taskContext else { fatalError() }
        let req = NSFetchRequest<RTCatalog>(entityName: "RTCatalog")
        req.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false), NSSortDescriptor(key: "text", ascending: true)]
        let array = try? context.fetch(req)
        return array
    }
    
    static func fetch(title: String) -> [RTCatalog]? {
        guard let context = CoreDataManager.instance.taskContext else { fatalError() }
        let req = NSFetchRequest<RTCatalog>(entityName: "RTCatalog")
        req.predicate = NSPredicate(format: "title = %@", title)
        req.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false), NSSortDescriptor(key: "text", ascending: true)]
        let array = try? context.fetch(req)
        return array
    }

    static func fetch(text: String) -> [RTCatalog]? {
        guard let context = CoreDataManager.instance.taskContext else { fatalError() }
        let req = NSFetchRequest<RTCatalog>(entityName: "RTCatalog")
        req.predicate = NSPredicate(format: "text = %@", text)
        req.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false), NSSortDescriptor(key: "text", ascending: true)]
        let array = try? context.fetch(req)
        return array
    }
    
    static func fetch(url: String) -> [RTCatalog]? {
        guard let context = CoreDataManager.instance.taskContext else { fatalError() }
        let req = NSFetchRequest<RTCatalog>(entityName: "RTCatalog")
        req.predicate = NSPredicate(format: "url = %@", url)
        req.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false), NSSortDescriptor(key: "text", ascending: true)]
        let array = try? context.fetch(req)
        return array
    }

}
