//
//  ArchiveDetail+.swift
//  LDLARadio
//
//  Created by fox on 13/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreData

extension ArchiveDetail {

    func extractFiles() -> Bool {
        var kAudios: Int = 0
        guard let currentFiles = archiveFiles?.array,
            currentFiles.isEmpty == true,
            let entityFile = ArchiveFile.entityName(),
            let context = RestApi.instance.context,
            let files = files else {
            return false
        }
        for (k, v) in files {
            if let key = k as? String,
                key.uppercased().split(separator: ".").last == "MP3" ||
                key.uppercased().split(separator: ".").last == "MP4",
                let json = v as? JSONDictionary {
                let archiveFile = try? object(withEntityName: entityFile, fromJSONDictionary: json, inContext: context) as? ArchiveFile
                archiveFile?.original = key
                archiveFile?.detail = self
                kAudios += 1
            }
        }
        if archiveFiles != nil, kAudios == 0 {
            return false
        } else {
            return true
        }
    }
}
