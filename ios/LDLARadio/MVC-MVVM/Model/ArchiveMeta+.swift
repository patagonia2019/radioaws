//
//  ArchiveMeta+.swift
//  LDLARadio
//
//  Created by fox on 11/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreData

extension ArchiveMeta: Modellable {

    static func all() -> [ArchiveMeta]? {
        return all(predicate: nil, sortDescriptors: [NSSortDescriptor(key: "response.start", ascending: true)]) as? [ArchiveMeta]
    }

    /// Fetch an parent object by id
    static func search(byCollectionIdentifier id: String?) -> ArchiveMeta? {
        guard let context = RestApi.instance.context else { fatalError() }
        guard let id = id else { return nil }
        let req = NSFetchRequest<ArchiveMeta>(entityName: "ArchiveMeta")
        req.predicate = NSPredicate(format: "collectionIdentifier = %@", id)
        let array = try? context.fetch(req)
        return array?.first
    }

    /// Fetch an object by id
    static func search(byIdentifier id: String?) -> ArchiveMeta? {
        guard let context = RestApi.instance.context else { fatalError() }
        guard let id = id else { return nil }
        let req = NSFetchRequest<ArchiveMeta>(entityName: "ArchiveMeta")
        req.predicate = NSPredicate(format: "identifier = %@", id)
        let array = try? context.fetch(req)
        return array?.first
    }
    
    var numFound: Int {
        return Int(response?.numFound ?? 0)
    }
}
