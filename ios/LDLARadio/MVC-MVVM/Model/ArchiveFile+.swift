//
//  ArchiveFile+.swift
//  LDLARadio
//
//  Created by fox on 13/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation

extension ArchiveFile {
    func urlString() -> String? {
        guard let server = detail?.server,
            let dir = detail?.dir,
            let original = original else {
                return nil
        }
        return "https://\(server)\(dir)\(original)"
    }
}
