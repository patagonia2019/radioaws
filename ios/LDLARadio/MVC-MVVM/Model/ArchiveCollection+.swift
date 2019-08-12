//
//  ArchiveCollection+.swift
//  LDLARadio
//
//  Created by fox on 12/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreData

extension ArchiveCollection : Modellable {
    
    static func all() -> [ArchiveCollection]? {
        return all(predicate: nil,
                   sortDescriptors: [NSSortDescriptor(key: "id", ascending: false)])
            as? [ArchiveCollection]
    }
    
}

extension ArchiveCollection {
    
    /// Returns the streams for a given name.
    static func search(byName name: String?) -> [ArchiveCollection]? {
        guard let context = RestApi.instance.context else { fatalError() }
        guard let name = name else { return nil }
        let req = NSFetchRequest<ArchiveCollection>(entityName: "ArchiveCollection")
        req.predicate = NSPredicate(format: "title = %@ OR title CONTAINS[cd] %@ OR subtitle = %@ OR subtitle CONTAINS[cd] %@ OR detail = %@ OR detail CONTAINS[cd] %@ OR identifier = %@ OR identifier CONTAINS[cd] %@", name, name, name, name, name, name, name, name)
        req.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false), NSSortDescriptor(key: "identifier", ascending: true)]
        let array = try? context.fetch(req)
        return array
    }
    
}


extension ArchiveCollection {
    
    /// Update the `updatedAt` field in the entity when the model is created
    override public func awakeFromInsert() {
        setPrimitiveValue(Date(), forKey: "updatedAt")
    }
    
    /// Fetch an object by id
    static func search(byIdentifier id: String?) -> ArchiveCollection? {
        guard let context = RestApi.instance.context else { fatalError() }
        guard let id = id else { return nil }
        let req = NSFetchRequest<ArchiveCollection>(entityName: "ArchiveCollection")
        req.predicate = NSPredicate(format: "id = %@", id)
        let array = try? context.fetch(req)
        return array?.first
    }
    
    func urlString() -> String? {
        if let identifier = identifier {
            return "\(RestApi.Constants.Service.archServer)/details/\(identifier)"
        }
        return nil
    }

    func searchUrlString() -> String? {
        if let identifier = identifier {
            return "\(RestApi.Constants.Service.archServer)/advancedsearch.php?q=\(identifier)&rows=50&page=1&save=yes#raw"
        }
        return nil
    }
    
}
