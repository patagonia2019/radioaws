//
//  ArchiveDoc+.swift
//  LDLARadio
//
//  Created by fox on 12/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreData
import Groot

extension ArchiveDoc {
    
    
    override public func didChangeValue(forKey key: String) {
        if key == "creatorTrf" {
            setPrimitiveValue(parseField(field: creatorTrf), forKey: "creator")
        }
        else if key == "subjectTrf" {
            setPrimitiveValue(parseField(field: subjectTrf), forKey: "subject")
        }
        else if key == "descriptTrf" {
            setPrimitiveValue(parseField(field: descriptTrf), forKey: "descript")
        }
        super.didChangeValue(forKey: key)
    }
        
    func thumbnailUrlString() -> String? {
        if let identifier = identifier {
            return "\(RestApi.Constants.Service.archServer)/services/img/\(identifier)"
        }
        return nil
    }

    func urlString() -> String? {
        if let identifier = identifier {
            return "\(RestApi.Constants.Service.archServer)/details/\(identifier)"
        }
        return nil
    }

    func extractFiles() {
        detail?.extractFiles()
    }

}

extension ArchiveDoc : Modellable {
    
    static func all() -> [ArchiveDoc]? {
        return all(predicate: nil,
                   sortDescriptors: [NSSortDescriptor(key: "title", ascending: false)])
            as? [ArchiveDoc]
    }
}

extension ArchiveDoc : Searchable {
    
    /// Fetch an object by url
    static func search(byUrl url: String?) -> ArchiveDoc? {
        guard let url = url else { return nil }
        guard let context = RestApi.instance.context else { fatalError() }
        let req = NSFetchRequest<ArchiveDoc>(entityName: "ArchiveDoc")
        req.predicate = NSPredicate(format: "urlString() = %@", url)
        let object = try? context.fetch(req).first
        return object
    }
    

    /// Returns the streams for a given name.
    static func search(byName name: String?) -> [ArchiveDoc]? {
        guard let context = RestApi.instance.context else { fatalError() }
        guard let name = name else { return nil }
        let req = NSFetchRequest<ArchiveDoc>(entityName: "ArchiveDoc")
        req.predicate = NSPredicate(format: "title = %@ OR title CONTAINS[cd] %@ OR descript = %@ OR descript CONTAINS[cd] %@ OR identifier = %@ OR identifier CONTAINS[cd] %@ OR subject = %@ OR subject CONTAINS[cd] %@ OR creator = %@ OR creator CONTAINS[cd] %@", name, name, name, name, name, name, name, name, name, name)
        req.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false), NSSortDescriptor(key: "identifier", ascending: true)]
        let array = try? context.fetch(req)
        return array
    }
    
    /// Fetch an object by id
    static func search(byIdentifier id: String?) -> ArchiveDoc? {
        guard let context = RestApi.instance.context else { fatalError() }
        guard let id = id else { return nil }
        let req = NSFetchRequest<ArchiveDoc>(entityName: "ArchiveDoc")
        req.predicate = NSPredicate(format: "identifier = %@", id)
        let array = try? context.fetch(req)
        return array?.first
    }

}



