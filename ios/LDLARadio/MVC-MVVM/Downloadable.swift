//
//  Downloadable.swift
//  LDLARadio
//
//  Created by fox on 26/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import AVFoundation

protocol Downloadable : Searchable {
    
    /// Returns the urlAsset of the stream
    func urlAsset() -> AVURLAsset?
    
    /// Returns the path of the downloaded instance of model (normaly podcast/audio/stream)
    func downloadedStream() -> URL?
}
