//
//  ArchiveMeta+.swift
//  LDLARadio
//
//  Created by fox on 11/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreData

extension ArchiveMeta : Modellable {
    
    static func all() -> [ArchiveMeta]? {
        return all(predicate: nil, sortDescriptors: [NSSortDescriptor(key: "response.start", ascending: true)]) as? [ArchiveMeta]
    }
    
}
