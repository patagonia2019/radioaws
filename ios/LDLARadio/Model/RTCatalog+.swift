//
//  RTCatalog+.swift
//  LDLARadio
//
//  Created by fox on 13/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Foundation

extension RTCatalog {
    func descript() -> String {
        var str = [String]()
        if let title = title { str.append(title) }
        if let text = text { str.append(text) }
        if let url = url { str.append(url) }
        if let key = key { str.append(key) }
        return str.joined(separator: ", ")
    }
}
