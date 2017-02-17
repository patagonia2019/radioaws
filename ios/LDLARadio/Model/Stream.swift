//
//  Stream.swift
//  LDLARadio
//
//  Created by Javier Fuchs on 1/6/17.
//  Copyright © 2017 Mobile Patagonia. All rights reserved.
//

import AVFoundation
import ObjectMapper

class Stream : Mappable {
    var id: Int?
    var name: String?
    var url_type: String?
    var station_id: Int?
    var created_at: Date?
    var updated_at: Date?
    var head_is_working: Bool?
    var listen_is_working: Bool?
    var use_web: Bool?
    var source_type: String?
    var url: String?
    
    /// The AVURLAsset corresponding to this Stream.
    var urlAsset: AVURLAsset?

    required public init?(map: Map) {
        
    }
    
    public init?(name: String, urlAsset: AVURLAsset) {
        
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        url_type <- map["url_type"]
        station_id <- map["station_id"]
        created_at <- (map["created_at"], DateTransform())
        updated_at <- (map["updated_at"], DateTransform())
        head_is_working <- map["head_is_working"]
        listen_is_working <- map["listen_is_working"]
        use_web <- map["use_web"]
        source_type <- map["source_type"]
        url <- map["url"]
    }
}

/// Extends `Stream` to conform to the `Equatable` protocol.
extension Stream: Equatable {}

func ==(lhs: Stream, rhs: Stream) -> Bool {
    return (lhs.name == rhs.name) && (lhs.urlAsset == rhs.urlAsset)
}


/**
 Extends `Stream` to add a simple download state enumeration used by the sample
 to track the download states of Assets.
 */
extension Stream {
    enum DownloadState: String {
        
        /// The asset is not downloaded at all.
        case notDownloaded
        
        /// The asset has a download in progress.
        case downloading
        
        /// The asset is downloaded and saved on diek.
        case downloaded
    }
}


/**
 Extends `Stream` to define a number of values to use as keys in dictionary lookups.
 */
extension Stream {
    struct Keys {
        /**
         Key for the Stream name, used for `StreamDownloadProgressNotification` and
         `StreamDownloadStateChangedNotification` Notifications as well as
         StreamListManager.
         */
        static let name = "AssetNameKey"
        
        /**
         Key for the Stream download percentage, used for
         `StreamDownloadProgressNotification` Notification.
         */
        static let percentDownloaded = "AssetPercentDownloadedKey"
        
        /**
         Key for the Stream download state, used for
         `StreamDownloadStateChangedNotification` Notification.
         */
        static let downloadState = "AssetDownloadStateKey"
        
        /**
         Key for the Stream download AVMediaSelection display Name, used for
         `StreamDownloadStateChangedNotification` Notification.
         */
        static let downloadSelectionDisplayName = "AssetDownloadSelectionDisplayNameKey"
    }
}

