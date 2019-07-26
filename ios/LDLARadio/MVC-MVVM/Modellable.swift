//
//  Modellable.swift
//  LDLARadio
//
//  Created by fox on 26/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import AVFoundation
import CoreData
import JFCore

protocol Modellable {
    
    func awakeFromInsert()
    
    /// Returns the urlAsset of the stream
    func urlAsset() -> AVURLAsset?
    
    /// Returns the path of the downloaded instance of model (normaly podcast/audio/stream)
    func downloadedStream() -> URL?
    
    /// Fetch the most recent updatedAt date
    static func lastUpdated() -> Date?
    
    /// Returns the streams for a given name.
    static func search(byName name: String?) -> NSManagedObject?
    
    /// Function to obtain all the instance of the model
    static func all() -> [NSManagedObject]?
    
    /// Remove all the instances of the entity
    static func clean()
}

