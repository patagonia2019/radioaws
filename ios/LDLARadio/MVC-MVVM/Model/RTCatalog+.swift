//
//  RTCatalog+.swift
//  LDLARadio
//
//  Created by fox on 13/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreData
import JFCore

extension RTCatalog {
    
    /// placeholder for thumbnails in streams
    static let placeholderImageName: String = "f0001-music"

    /// Update the `updatedAt` field in the entity when the model is created
    override public func awakeFromInsert() {
        setPrimitiveValue(Date(), forKey: "updatedAt")
    }
    
    /// returns the title or text of the catalog
    func titleOrText() -> String? {
        return title ?? text
    }
    
    /// Builds a tree of hierarchy in the catalog to show in prompt view controller, smth like: "Browse > Europe > Radios"
    func titleTree() -> String {
        var str = ArraySlice<String>()
        if let t0 = sectionCatalog?.titleTree() {
            str.append(t0 + "> ")
        }
        if let t1 = titleOrText() {
            str.append(t1)
        }
        /// Does not allow more than 30 characters in prompt
        while str.joined().count > 30 && str.count > 1 {
            _ = str.popFirst()
        }
        return str.joined()
    }
    
    /// convenient for debug or print info about catalog
    func descript() -> String {
        var str = [String]()
        if let title = title { str.append(title) }
        if let url = url { str.append(url) }
        if let key = key { str.append(key) }
        if let sections = sections { str.append("\(sections) sections") }
        if let audios = audios { str.append("\(audios.count) audios") }
        return str.joined(separator: ", ")
    }
    
    /// Remove all the instances
    static func clean() {
        guard let context = RestApi.instance.context else {
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
    
    /// Remove current instance
    func remove() {
        guard let context = RestApi.instance.context else {
            fatalError("fatal: no core data context manager")
        }
        context.delete(self)
    }
    
    /// Determine if the catalog is about text information
    func isOnlyText() -> Bool {
        return type == "text" || (sections?.count == 0 && audios?.count == 0 && title != "Browse")
    }
    
    /// Determine if the catalog is about audio information
    func isAudio() -> Bool {
        return type == "audio"
    }
    
    /// Determine if the catalog is about link information
    func isLink() -> Bool {
        return type == nil || type == "link"
    }
    
    /// Fetch all the objects in DB
    static func all() -> [RTCatalog]? {
        guard let context = RestApi.instance.context else { fatalError() }
        let req = NSFetchRequest<RTCatalog>(entityName: "RTCatalog")
        req.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false), NSSortDescriptor(key: "text", ascending: true)]
        let array = try? context.fetch(req)
        return array
    }
    
    /// Fetch the most recent updatedAt date
    static func lastUpdated() -> Date? {
        guard let context = RestApi.instance.context else { fatalError() }
        let req = NSFetchRequest<RTCatalog>(entityName: "RTCatalog")
        req.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        return try? context.fetch(req).first?.updatedAt
    }

    /// Fetch an object by title
    static func fetch(title: String) -> [RTCatalog]? {
        guard let context = RestApi.instance.context else { fatalError() }
        let req = NSFetchRequest<RTCatalog>(entityName: "RTCatalog")
        req.predicate = NSPredicate(format: "title = %@", title)
        req.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false), NSSortDescriptor(key: "text", ascending: true)]
        let array = try? context.fetch(req)
        return array
    }

    /// Fetch an object by text
    static func fetch(text: String) -> [RTCatalog]? {
        guard let context = RestApi.instance.context else { fatalError() }
        let req = NSFetchRequest<RTCatalog>(entityName: "RTCatalog")
        req.predicate = NSPredicate(format: "text = %@", text)
        req.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false), NSSortDescriptor(key: "text", ascending: true)]
        let array = try? context.fetch(req)
        return array
    }
    
    /// Fetch an object by url
    static func fetch(url: String) -> [RTCatalog]? {
        guard let context = RestApi.instance.context else { fatalError() }
        let req = NSFetchRequest<RTCatalog>(entityName: "RTCatalog")
        req.predicate = NSPredicate(format: "url = %@", url)
        req.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false), NSSortDescriptor(key: "text", ascending: true)]
        let array = try? context.fetch(req)
        return array
    }

}
