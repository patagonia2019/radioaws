//
//  Desconcierto+.swift
//  LDLARadio
//
//  Created by fox on 28/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation

extension Desconcierto : Modellable {
    
    /// Function to obtain all the quotes
    static func all() -> [Desconcierto]? {
        return all(predicate: nil,
                   sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)])
            as? [Desconcierto]
    }

}
