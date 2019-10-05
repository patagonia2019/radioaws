//
//  City+.swift
//  LDLARadio
//
//  Created by fox on 23/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreData

extension City: Modellable {

    /// Function to obtain all the albums sorted by title
    static func all() -> [City]? {
        return all(predicate: nil, sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) as? [City]
    }

}
