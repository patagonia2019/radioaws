//
//  Stream.swift
//  LDLARadio
//
//  Created by Javier Fuchs on 1/6/17.
//  Copyright © 2017 Mobile Patagonia. All rights reserved.
//

import Foundation
import AVFoundation
import CoreData

extension Stream : Modellable {
    
    /// Function to obtain all the streams sorted by station.name
    static func all() -> [Stream]? {
        return all(predicate: NSPredicate(format: "listenIsWorking = true and useWeb = false"),
                   sortDescriptors: [NSSortDescriptor(key: "station.name",
                                                      ascending: true)])
            as? [Stream]
    }
}

extension Stream : Searchable {
    
    /// Returns the entities for a given name.
    static func search(byName name: String?) -> [Stream]? {
        guard let context = RestApi.instance.context else { fatalError() }
        guard let name = name else { return nil }
        let req = NSFetchRequest<Stream>(entityName: "Stream")
        req.predicate = NSPredicate(format: "station.name == %@ OR station.name CONTAINS[cd] %@ OR station.city.name == %@ OR station.city.name CONTAINS[cd] %@ OR station.city.district.name == %@ OR station.city.district.name CONTAINS[cd] %@", name, name, name, name, name, name)
        let array = try? context.fetch(req)
        return array
    }

    
    /// Fetch an object by url
    static func search(byUrl url: String?) -> Stream? {
        guard let context = RestApi.instance.context else { fatalError() }
        guard let url = url else { return nil }
        let req = NSFetchRequest<Stream>(entityName: "Stream")
        req.predicate = NSPredicate(format: "url = %@", url)
        let array = try? context.fetch(req)
        return array?.first
    }

}

extension Stream : Downloadable {

    /// Returns the urlAsset of the stream
    func urlAsset() -> AVURLAsset? {
        guard let playUrl = url?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let streamPlaylistURL = URL(string: playUrl),
            listenIsWorking else { return nil }
        return AVURLAsset(url: streamPlaylistURL)
    }

    /// Returns the path of the downloaded stream
    func downloadedStream() -> URL? {
        let userDefaults = UserDefaults.standard
        guard let urlString = url,
            let localFileLocation = userDefaults.value(forKey: urlString) as? String else { return nil }
        let baseDownloadURL = URL(fileURLWithPath: NSHomeDirectory())
        
        let urlPath = baseDownloadURL.appendingPathComponent(localFileLocation)
        
        return urlPath
    }
    
}

extension Stream {
    
    /// Returns the streams for a given station id.
    static func stream(byStation stationId: Int16?) -> [Stream]? {
        guard let context = RestApi.instance.context else { fatalError() }
        guard let stationId = stationId else { return nil }
        let req = NSFetchRequest<Stream>(entityName: "Stream")
        req.predicate = NSPredicate(format: "station.id = %d", stationId)
        req.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let array = try? context.fetch(req)
        return array
    }
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

