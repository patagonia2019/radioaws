//
//  StreamListManager.swift
//  LDLARadio
//
//  Created by Javier Fuchs on 1/6/17.
//  Copyright © 2017 Mobile Patagonia. All rights reserved.
//

import Foundation
import AVFoundation
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import JFCore

class StreamListManager: NSObject {
    // MARK: Properties
    
    /// A singleton instance of StreamListManager.
    static let sharedManager = StreamListManager()
    
    /// Notification for when download progress has changed.
    static let didLoadNotification = NSNotification.Name(rawValue: "StreamListManagerDidLoadNotification")

    static let errorNotification = NSNotification.Name(rawValue: "StreamListManagerErrorNotification")

    /// The internal array of Stream structs.
    private var streams = [Stream]()
    
    // MARK: Initialization
    
    override private init() {
        super.init()
        
        /*
         Do not setup the StreamListManager.assets until StreamPersistenceManager has
         finished restoring.  This prevents race conditions where the `StreamListManager`
         creates a list of `Stream`s that doesn't reuse already existing `AVURLAssets`
         from existng `AVAssetDownloadTasks.
         */
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleStreamPersistenceManagerDidRestoreStateNotification(_:)), name: StreamPersistenceManagerDidRestoreStateNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: StreamPersistenceManagerDidRestoreStateNotification, object: nil)
    }
    
    // MARK: Stream access
    
    /// Returns the number of Streams.
    func numberOfStreams() -> Int {
        return streams.count
    }
    
    /// Returns an Stream for a given IndexPath.
    func stream(at index: Int) -> Stream {
        return streams[index]
    }

    /// Returns the streams for a given station id.
    func stream(byStation stationId: Int?) -> [Stream]? {
        var array = [Stream]()
        for stream in streams {
            if stream.station_id == stationId {
                array.append(stream)
            }
        }
        return array
    }
 
    func handleStreamPersistenceManagerDidRestoreStateNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            guard let server = UserDefaults.standard.string(forKey: "server_url") else {
                return
            }
            let streamsJsonUrl = server + "/streams.json"

            Alamofire.request(streamsJsonUrl, method:.get).validate().responseArray { (response: DataResponse<[Stream]>) in
                if let result = response.result.value {
                    for entry in result {
                        // Get the Stream name from the dictionary
                        guard let streamName = entry.name else { continue }
                        
                        // To ensure that we are reusing AVURLAssets we first find out if there is one available for an already active download.
                        if let asset = StreamPersistenceManager.sharedManager.assetForStream(withName: streamName) {
                            guard let url = asset.name,
                                let streamPlaylistURL = URL(string: url),
                                let isWorking = asset.listen_is_working,
                                isWorking else { continue }
                            asset.urlAsset = AVURLAsset(url: streamPlaylistURL)
                            self.streams.append(asset)
                        }
                        else {
                            /*
                             If an existing `AVURLAsset` is not available for an active
                             download we then see if there is a file URL available to
                             create an asset from.
                             */
                            if let asset = StreamPersistenceManager.sharedManager.localAssetForStream(withName: streamName) {
                                guard let url = asset.name,
                                    let streamPlaylistURL = URL(string: url),
                                    let isWorking = asset.listen_is_working,
                                    isWorking else { continue }
                                asset.urlAsset = AVURLAsset(url: streamPlaylistURL)
                                self.streams.append(asset)
                            }
                            else {
                                guard let url = entry.name,
                                    let streamPlaylistURL = URL(string: url),
                                    let isWorking = entry.listen_is_working,
                                    isWorking else { continue }
                                entry.urlAsset = AVURLAsset(url: streamPlaylistURL)
                                self.streams.append(entry)
                            }
                        }
                    }
                    NotificationCenter.default.post(name: StreamListManager.didLoadNotification, object: self)
                }
                else if let error = response.result.error {
                    let myerror = JFError(code: 101,
                                          desc: "failed to get appId=\(1) userId=\(1) locationId=\(1)",
                        reason: "something get wrong on request \(streamsJsonUrl)", suggestion: "\(#file):\(#line):\(#column):\(#function)",
                        underError: error as NSError?)
                    NotificationCenter.default.post(name: StreamListManager.errorNotification, object: self)
                }
            }
        }
    }
}
