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
                   sortDescriptors: [NSSortDescriptor(key: "title", ascending: true)])
            as? [ArchiveCollection]
    }
    
}

extension ArchiveCollection : Creational {
    
    /// Create bookmark entity programatically
    static func create() -> ArchiveCollection? {
        guard let context = RestApi.instance.context else { fatalError() }
        guard let entity = NSEntityDescription.entity(forEntityName: "ArchiveCollection", in: context) else {
            fatalError()
        }
        let object = NSManagedObject(entity: entity, insertInto: context) as? ArchiveCollection
        return object
    }

}

extension ArchiveCollection {
    
    /// Fetch an object by url
    static func search(byUrl url: String?) -> ArchiveCollection? {
        guard let url = url else { return nil }
        guard let context = RestApi.instance.context else { fatalError() }
        let req = NSFetchRequest<ArchiveCollection>(entityName: "ArchiveCollection")
        req.predicate = NSPredicate(format: "urlString() = %@", url)
        let object = try? context.fetch(req).first
        return object
    }
    

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
        req.predicate = NSPredicate(format: "identifier = %@", id)
        let array = try? context.fetch(req)
        return array?.first
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
    

    func searchCollectionUrlString(page: Int = 1) -> String? {
        if let identifier = identifier {
            return "\(RestApi.Constants.Service.archServer)/advancedsearch.php?q=collection:(\(identifier))+AND+mediatype:(audio)&fl[]=creator&fl[]=description&fl[]=downloads&fl[]=identifier&fl[]=item_size&fl[]=mediatype&fl[]=publicdate&fl[]=subject&fl[]=title&fl[]=type&sort[]=downloads+desc&sort[]=&sort[]=&rows=10&page=\(page)"

        }
        return nil
    }
    

    static func searchUrlString(withString string: String, page: Int = 1) -> String? {
        return "\(RestApi.Constants.Service.archServer)/advancedsearch.php?q=\(string)+AND+mediatype:(audio)&fl[]=creator&fl[]=description&fl[]=downloads&fl[]=identifier&fl[]=item_size&fl[]=mediatype&fl[]=publicdate&fl[]=subject&fl[]=title&fl[]=type&sort[]=downloads+desc&sort[]=&sort[]=&rows=10&page=\(page)"
    }
    
}
