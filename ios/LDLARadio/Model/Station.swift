//
//  Station.swift
//  LDLARadio
//
//  Created by javierfuchs on 1/12/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class Station : Mappable {
    var id: Int?
    var name: String?
    var tunning_dial: String?
    var internal_hash: String?
    var is_am: Bool?
    var imageUrl: String?
    var city_id: Int?
    var created_at: Date?
    var updated_at: Date?
    var url: String?
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        tunning_dial <- map["tunning_dial"]
        internal_hash <- map["internal_hash"]
        is_am <- map["is_am"]
        imageUrl <- map["imageUrl"]
        city_id <- map["city_id"]
        created_at <- (map["created_at"], DateTransform())
        updated_at <- (map["updated_at"], DateTransform())
        url <- map["url"]
    }
}

