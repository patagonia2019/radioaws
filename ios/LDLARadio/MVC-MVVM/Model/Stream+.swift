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
import JFCore

extension Stream {
    
    override public func awakeFromInsert() {
        setPrimitiveValue(Date(), forKey: "updatedAt")
    }

    func urlAsset() -> AVURLAsset? {
        guard let playUrl = name?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let streamPlaylistURL = URL(string: playUrl),
            listenIsWorking else { return nil }
        return AVURLAsset(url: streamPlaylistURL)
    }
    
    func downloadedStream() -> URL? {
        let userDefaults = UserDefaults.standard
        guard let name = name,
            let localFileLocation = userDefaults.value(forKey: name) as? String else { return nil }
        let baseDownloadURL = URL(fileURLWithPath: NSHomeDirectory())

        let url = baseDownloadURL.appendingPathComponent(localFileLocation)
        
        return url
    }
    
    
    /// Returns the streams for a given station id.
    static func stream(byName name: String?) -> Stream? {
        guard let context = CoreDataManager.instance.taskContext else { fatalError() }
        guard let name = name else { return nil }
        let req = NSFetchRequest<Stream>(entityName: "Stream")
        req.predicate = NSPredicate(format: "name = %s", name)
        let array = try? context.fetch(req)
        return array?.first
    }
    
    /// Returns the streams for a given station id.
    static func stream(byStation stationId: Int16?) -> [Stream]? {
        guard let context = CoreDataManager.instance.taskContext else { fatalError() }
        guard let stationId = stationId else { return nil }
        let req = NSFetchRequest<Stream>(entityName: "Stream")
        req.predicate = NSPredicate(format: "station.id = %d", stationId)
        req.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let array = try? context.fetch(req)
        return array
    }
    
    /// Function to obtain all the streams sorted by station.name
    static func all() -> [Stream]? {
        guard let context = CoreDataManager.instance.taskContext else { fatalError() }
        let req = NSFetchRequest<Stream>(entityName: "Stream")
        req.predicate = NSPredicate(format: "listenIsWorking = true")
        req.sortDescriptors = [NSSortDescriptor(key: "station.name", ascending: true)]
        let array = try? context.fetch(req)
        return array
    }

    
    static func clean() {
        guard let context = CoreDataManager.instance.taskContext else {
            fatalError("fatal: no core data context manager")
        }
        let req = NSFetchRequest<Stream>(entityName: "Stream")
        req.includesPropertyValues = false
        if let array = try? context.fetch(req as! NSFetchRequest<NSFetchRequestResult>) as? [NSManagedObject] {
            for obj in array {
                context.delete(obj)
            }
        }
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

