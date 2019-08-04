//
//  RNAStation+.swift
//  LDLARadio
//
//  Created by fox on 23/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreData

extension RNAStation : Modellable {
    
    /// Function to obtain all the albums sorted by title
    static func all() -> [RNAStation]? {
        return all(predicate: nil, sortDescriptors: [NSSortDescriptor.init(key: "lastName", ascending: true)]) as? [RNAStation]
    }
    
}

extension RNAStation : Searchable {
    
    /// Fetch an object by url
    static func search(byUrl url: String?) -> RNAStation? {
        guard let url = url else { return nil }
        guard let context = RestApi.instance.context else { fatalError() }
        let req = NSFetchRequest<RNAStation>(entityName: "RNAStation")
        req.predicate = NSPredicate(format: "url1 = %@ OR url2 = %@", url, url)
        let object = try? context.fetch(req).first
        return object
    }
    
    /// Returns the streams for a given name.
    static func search(byName name: String?) -> [RNAStation]? {
        guard let context = RestApi.instance.context else { fatalError() }
        guard let name = name else { return nil }
        let req = NSFetchRequest<RNAStation>(entityName: "RNAStation")
        req.predicate = NSPredicate(format: "lastName = %@ OR lastName CONTAINS[cd] %@ OR firstName = %@ OR firstName CONTAINS[cd] %@", name, name, name, name)
        let array = try? context.fetch(req)
        return array
    }
    

}
