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
        guard let context = RestApi.instance.context else { fatalError() }
        if archiveFiles?.isEmpty == false {
            if let files = files {
                for (k, v) in files {
                    if let key = k as? String,
                        key.uppercased().split(separator: ".").last == "MP3",
                        let json = v as? JSONDictionary {
                        let arcFile = try? object(withEntityName: "ArchiveFile", fromJSONDictionary: json, inContext: context) as? ArchiveFile
                        arcFile?.original = key
                        arcFile?.detail = self
                    }
                }
             }
        }
    }

}
