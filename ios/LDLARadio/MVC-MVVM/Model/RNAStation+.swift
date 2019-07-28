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

extension RNAStation {
    /// placeholder for thumbnails in streams
    static let placeholderImageName: String = "RNA-256x256bb"

    /// Fetch an instance using the id
    static func searchBy(id: String?) -> RNAStation? {
        guard let context = RestApi.instance.context else { fatalError() }
        let req = NSFetchRequest<RNAStation>(entityName: "RNAStation")
        guard let id = id else { return nil }
        req.predicate = NSPredicate(format: "id = %@", id)
        let station = try? context.fetch(req).first
        return station
    }
}
