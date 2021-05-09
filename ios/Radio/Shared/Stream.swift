//
//  Stream.swift
//  Radio
//
//  Created by fox on 08/05/2021.
//

import CoreData

enum DecoderConfigurationError: Error {
    case missingManagedObjectContext
}

class Stream: NSManagedObject, Decodable {
        
    enum CodingKeys: CodingKey {
        case id, detail, imageUrl, name, station, streamUrl
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        
        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.detail = try container.decode(String.self, forKey: .detail)
        self.imageUrl = try container.decode(String.self, forKey: .imageUrl)
        self.name = try container.decode(String.self, forKey: .name)
        self.streamUrl = try container.decode(String.self, forKey: .streamUrl)
    }
}

struct StreamResponse: Decodable {
    let versionToken: String
    let streams: [Stream]
}
