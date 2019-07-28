//
//  RNAProgram+.swift
//  LDLARadio
//
//  Created by fox on 23/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreData

extension RNAProgram : Modellable {
    
    /// Function to obtain all the albums sorted by title
    static func all() -> [RNAProgram]? {
        return all(predicate: nil, sortDescriptors: [NSSortDescriptor.init(key: "name", ascending: true)]) as? [RNAProgram]
    }
    
}
