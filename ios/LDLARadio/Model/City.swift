//
//  City.swift
//  LDLARadio
//
//  Created by javierfuchs on 1/12/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class City : Mappable {
    var id: Int?
    var name: String?
    var district_id: Int?
    var created_at: Date?
    var updated_at: Date?
    var url: String?
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        district_id <- map["district_id"]
        created_at <- (map["created_at"], DateTransform())
        updated_at <- (map["updated_at"], DateTransform())
        url <- map["url"]
    }
}

