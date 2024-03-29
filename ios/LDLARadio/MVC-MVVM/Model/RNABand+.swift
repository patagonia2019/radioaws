//
//  RNABand+.swift
//  LDLARadio
//
//  Created by fox on 23/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreData

extension RNABand: Modellable {

    /// Function to obtain all the albums sorted by title
    static func all() -> [RNABand]? {
        return all(predicate: nil, sortDescriptors: nil) as? [RNABand]
    }

}
