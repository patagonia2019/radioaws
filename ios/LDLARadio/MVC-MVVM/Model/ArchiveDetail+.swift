//
//  ArchiveDetail+.swift
//  LDLARadio
//
//  Created by fox on 13/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreData
import Groot

extension ArchiveDetail {

    func extractFiles() {
        guard let archiveFiles = archiveFiles?.array,
            archiveFiles.isEmpty == true,
            let entityFile = ArchiveFile.entityName(),
            let context = RestApi.instance.context,
            let files = files else { return }
        for (k, v) in files {
            if let key = k as? String,
                key.uppercased().split(separator: ".").last == "MP3",
                let json = v as? JSONDictionary {
                let archiveFile = try? object(withEntityName: entityFile, fromJSONDictionary: json, inContext: context) as? ArchiveFile
                archiveFile?.original = key
                archiveFile?.detail = self
            }
        }
    }
}
