//
//  StreamPersistenceManager.swift
//  LDLARadio
//
//  Created by Javier Fuchs on 1/6/17.
//  Copyright © 2017 Mobile Patagonia. All rights reserved.
//

import Foundation
import AVFoundation

/// Notification for when download progress has changed.
let StreamDownloadProgressNotification: NSNotification.Name = NSNotification.Name(rawValue: "StreamDownloadProgressNotification")

/// Notification for when the download state of an Stream has changed.
let StreamDownloadStateChangedNotification: NSNotification.Name = NSNotification.Name(rawValue: "StreamDownloadStateChangedNotification")

/// Notification for when StreamPersistenceManager has completely restored its state.
let StreamPersistenceManagerDidRestoreStateNotification: NSNotification.Name = NSNotification.Name(rawValue: "StreamPersistenceManagerDidRestoreStateNotification")

/// Notification for when StationPersistenceManager has completely restored its state.
let StationPersistenceManagerDidRestoreStateNotification: NSNotification.Name = NSNotification.Name(rawValue: "StationPersistenceManagerDidRestoreStateNotification")

let CityPersistenceManagerDidRestoreStateNotification: NSNotification.Name = NSNotification.Name(rawValue: "CityPersistenceManagerDidRestoreStateNotification")

class StreamPersistenceManager: NSObject {
    // MARK: Properties
    
    /// Singleton for StreamPersistenceManager.
    static let sharedManager = StreamPersistenceManager()
    
    /// Internal Bool used to track if the StreamPersistenceManager finished restoring its state.
    private var didRestorePersistenceManager = false
    
    /// The AVAssetDownloadURLSession to use for managing AVAssetDownloadTasks.
    fileprivate var assetDownloadURLSession: AVAssetDownloadURLSession!
    
    /// Internal map of AVAssetDownloadTask to its corresponding Stream.
    fileprivate var activeDownloadsMap = [AnyHashable : Stream]()
    
    /// Internal map of AVAssetDownloadTask to its resoled AVMediaSelection
    fileprivate var mediaSelectionMap = [AnyHashable : AVMediaSelection]()
    
    /// The URL to the Library directory of the application's data container.
    fileprivate let baseDownloadURL: URL
    
    // MARK: Intialization
    
    override private init() {
        
        baseDownloadURL = URL(fileURLWithPath: NSHomeDirectory())
        
        super.init()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true) }
        catch let error as NSError { print(error) }
                
        // Create the configuration for the AVAssetDownloadURLSession.
        let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: "AAPL-Identifier")
        
        // Create the AVAssetDownloadURLSession using the configuration.
        if #available(iOS 10.0, *) {
            assetDownloadURLSession = AVAssetDownloadURLSession(configuration: backgroundConfiguration, assetDownloadDelegate: self, delegateQueue: OperationQueue.main)
        }
    }
    
    /// Restores the Application state by getting all the AVAssetDownloadTasks and restoring their Stream structs.
    func restorePersistenceManager() {
        guard !didRestorePersistenceManager else { return }
        
        didRestorePersistenceManager = true
        
        _ = StreamListManager.sharedManager;
        _ = CityListManager.sharedManager;
        _ = StationListManager.sharedManager;
        
        NotificationCenter.default.post(name: CityPersistenceManagerDidRestoreStateNotification, object: nil)
        
        NotificationCenter.default.post(name: StationPersistenceManagerDidRestoreStateNotification, object: nil)

        // Grab all the tasks associated with the assetDownloadURLSession
        if #available(iOS 10.0, *) {
            assetDownloadURLSession.getAllTasks { tasksArray in
                // For each task, restore the state in the app by recreating Stream structs and reusing existing AVURLAsset objects.
                for task in tasksArray {
                    guard let assetDownloadTask = task as? AVAssetDownloadTask, let assetName = task.taskDescription else { break }
                    
                    let asset = Stream(name: assetName, urlAsset: assetDownloadTask.urlAsset)
                    self.activeDownloadsMap[assetDownloadTask] = asset
                }
                
                NotificationCenter.default.post(name: StreamPersistenceManagerDidRestoreStateNotification, object: nil)
            }
        }
        else {
            NotificationCenter.default.post(name: StreamPersistenceManagerDidRestoreStateNotification, object: nil)
        }
    }
    
    /// Triggers the initial AVAssetDownloadTask for a given Stream.
    func downloadStream(for asset: Stream) {
        /*
         For the initial download, we ask the URLSession for an AVAssetDownloadTask
         with a minimum bitrate corresponding with one of the lower bitrate variants
         in the asset.
         */
        let assetDownloadTask: AVAssetDownloadTask?
        
        if #available(iOS 10.0, *) {
            guard let name = asset.name,
                  let urlAsset = asset.urlAsset else { return }
            assetDownloadTask = assetDownloadURLSession.makeAssetDownloadTask(asset: urlAsset, assetTitle: name, assetArtworkData: nil, options: [AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: 265000])
        } else {
            guard let name = asset.name,
                let urlAsset = asset.urlAsset else { return }
            
            guard let url = urlForStream(withName: name) else {
                return
            }
            
            assetDownloadTask = assetDownloadURLSession.makeAssetDownloadTask(asset: urlAsset, destinationURL: url, options: [AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: 265000])
        }
        
        guard let task = assetDownloadTask else {
            return
        }
        
        // To better track the AVAssetDownloadTask we set the taskDescription to something unique for our sample.
        task.taskDescription = asset.name
        
        activeDownloadsMap[task] = asset
        
        task.resume()
        
        var userInfo = [String: Any]()
        userInfo[Stream.Keys.name] = asset.name
        userInfo[Stream.Keys.downloadState] = Stream.DownloadState.downloading.rawValue
        
        NotificationCenter.default.post(name: StreamDownloadStateChangedNotification, object: nil, userInfo:  userInfo)
    }
    
    /// Returns an Stream given a specific name if that Stream is asasociated with an active download.
    func assetForStream(withName name: String) -> Stream? {
        var asset: Stream?
        
        for (_, assetValue) in activeDownloadsMap {
            if name == assetValue.name {
                asset = assetValue
                break
            }
        }
        
        return asset
    }
    
    /// Returns the Url pointing to a file on disk if it exists.
    func urlForStream(withName name: String) -> URL? {
        let userDefaults = UserDefaults.standard
        guard let localFileLocation = userDefaults.value(forKey: name) as? String else { return nil }
        
        let url = baseDownloadURL.appendingPathComponent(localFileLocation)
        
        return url
    }
    
    /// Returns an Stream pointing to a file on disk if it exists.
    func localAssetForStream(withName name: String) -> Stream? {
        var asset: Stream?
        guard let url = urlForStream(withName: name) else {
            return nil
        }
        asset = Stream(name: name, urlAsset: AVURLAsset(url: url))
        
        return asset
    }
    
    /// Returns the current download state for a given Stream.
    func downloadState(for asset: Stream) -> Stream.DownloadState {
        let userDefaults = UserDefaults.standard
        
        // Check if there is a file URL stored for this asset.
        guard let name = asset.name else { return .notDownloaded}

        if let localFileLocation = userDefaults.value(forKey: name) as? String{
            // Check if the file exists on disk
            let localFilePath = baseDownloadURL.appendingPathComponent(localFileLocation).path
            
            if localFilePath == baseDownloadURL.path {
                return .notDownloaded
            }
            
            if FileManager.default.fileExists(atPath: localFilePath) {
                return .downloaded
            }
        }
        
        // Check if there are any active downloads in flight.
        for (_, assetValue) in activeDownloadsMap {
            if asset.name == assetValue.name {
                return .downloading
            }
        }
        
        return .notDownloaded
    }
    
    /// Deletes an Stream on disk if possible.
    func deleteAsset(_ asset: Stream) {
        let userDefaults = UserDefaults.standard
        
        do {
            guard let name = asset.name else { return }

            if let localFileLocation = userDefaults.value(forKey: name) as? String {
                let localFileLocation = baseDownloadURL.appendingPathComponent(localFileLocation)
                try FileManager.default.removeItem(at: localFileLocation)
                
                userDefaults.removeObject(forKey: name)
                
                var userInfo = [String: Any]()
                userInfo[Stream.Keys.name] = asset.name
                userInfo[Stream.Keys.downloadState] = Stream.DownloadState.notDownloaded.rawValue
                
                NotificationCenter.default.post(name: StreamDownloadStateChangedNotification, object: nil, userInfo:  userInfo)
            }
        } catch {
            print("An error occured deleting the file: \(error)")
        }
    }
    
    /// Cancels an AVAssetDownloadTask given an Stream.
    func cancelDownload(for asset: Stream) {
        var task: AVAssetDownloadTask?
        
        for (taskKey, assetVal) in activeDownloadsMap {
            if asset == assetVal  {
                guard let taskObj = taskKey as? AVAssetDownloadTask else {
                    continue
                }
                task = taskObj
                break
            }
        }
        
        task?.cancel()
    }
    
    // MARK: Convenience
    
    /**
     This function demonstrates returns the next `AVMediaSelectionGroup` and
     `AVMediaSelectionOption` that should be downloaded if needed. This is done
     by querying an `AVURLAsset`'s `AVAssetCache` for its available `AVMediaSelection`
     and comparing it to the remote versions.
     */
    fileprivate func nextMediaSelection(_ asset: AVURLAsset) -> (mediaSelectionGroup: AVMediaSelectionGroup?, mediaSelectionOption: AVMediaSelectionOption?) {
        if #available(iOS 10.0, *) {

            guard let assetCache = asset.assetCache else { return (nil, nil) }

            let mediaCharacteristics = [AVMediaCharacteristicAudible, AVMediaCharacteristicLegible]
            
            for mediaCharacteristic in mediaCharacteristics {
                if let mediaSelectionGroup = asset.mediaSelectionGroup(forMediaCharacteristic: mediaCharacteristic) {
                    let savedOptions = assetCache.mediaSelectionOptions(in: mediaSelectionGroup)
                    
                    if savedOptions.count < mediaSelectionGroup.options.count {
                        // There are still media options left to download.
                        for option in mediaSelectionGroup.options {
                            if !savedOptions.contains(option) {
                                // This option has not been download.
                                return (mediaSelectionGroup, option)
                            }
                        }
                    }
                }
            }
        }

        // At this point all media options have been downloaded.
        return (nil, nil)
    }
}

/**
 Extend `AVAssetDownloadDelegate` to conform to the `AVAssetDownloadDelegate` protocol.
 */
extension StreamPersistenceManager: AVAssetDownloadDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let userDefaults = UserDefaults.standard
        
        /*
         This is the ideal place to begin downloading additional media selections
         once the asset itself has finished downloading.
         */
        guard let task = task as? AVAssetDownloadTask , let asset = activeDownloadsMap.removeValue(forKey: task) else { return }
        
        // Prepare the basic userInfo dictionary that will be posted as part of our notification.
        var userInfo = [String: Any]()
        userInfo[Stream.Keys.name] = asset.name
        
        if let error = error as? NSError {
            switch (error.domain, error.code) {
            case (NSURLErrorDomain, NSURLErrorCancelled):
                /*
                 This task was canceled, you should perform cleanup using the
                 URL saved from AVAssetDownloadDelegate.urlSession(_:assetDownloadTask:didFinishDownloadingTo:).
                 */
                guard   let name = asset.name,
                        let localFileLocation = userDefaults.value(forKey: name) as? String else { return }
                
                do {
                    let fileURL = baseDownloadURL.appendingPathComponent(localFileLocation)
                    try FileManager.default.removeItem(at: fileURL)
                    
                    userDefaults.removeObject(forKey: name)
                } catch {
                    print("An error occured trying to delete the contents on disk for \(asset.name): \(error)")
                }
                
                userInfo[Stream.Keys.downloadState] = Stream.DownloadState.notDownloaded.rawValue
                
            case (NSURLErrorDomain, NSURLErrorUnknown):
                fatalError("Downloading HLS streams is not supported in the simulator.")
                
            default:
                fatalError("An unexpected error occured \(error.domain)")
            }
        }
        else {
            let mediaSelectionPair = nextMediaSelection(task.urlAsset)
            
            if mediaSelectionPair.mediaSelectionGroup != nil {
                /*
                 This task did complete sucessfully. At this point the application
                 can download additional media selections if needed.
                 
                 To download additional `AVMediaSelection`s, you should use the
                 `AVMediaSelection` reference saved in `AVAssetDownloadDelegate.urlSession(_:assetDownloadTask:didResolve:)`.
                 */
                
                guard let originalMediaSelection = mediaSelectionMap[task] else { return }
                
                /*
                 There are still media selections to download.
                 
                 Create a mutable copy of the AVMediaSelection reference saved in
                 `AVAssetDownloadDelegate.urlSession(_:assetDownloadTask:didResolve:)`.
                 */
                let mediaSelection = originalMediaSelection.mutableCopy() as! AVMutableMediaSelection
                
                // Select the AVMediaSelectionOption in the AVMediaSelectionGroup we found earlier.
                mediaSelection.select(mediaSelectionPair.mediaSelectionOption!, in: mediaSelectionPair.mediaSelectionGroup!)
                
                /*
                 Ask the `URLSession` to vend a new `AVAssetDownloadTask` using
                 the same `AVURLAsset` and assetTitle as before.
                 
                 This time, the application includes the specific `AVMediaSelection`
                 to download as well as a higher bitrate.
                 */
                
                let assetDownloadTask: AVAssetDownloadTask?
                
                guard let name = asset.name,
                      let urlAsset = asset.urlAsset else { return }
                if #available(iOS 10.0, *) {
                    assetDownloadTask = assetDownloadURLSession.makeAssetDownloadTask(asset: task.urlAsset, assetTitle: name, assetArtworkData: nil, options: [AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: 2000000, AVAssetDownloadTaskMediaSelectionKey: mediaSelection])
                    
                } else {
                    
                    guard let url = urlForStream(withName: name) else {
                        return
                    }
                    
                    assetDownloadTask = assetDownloadURLSession.makeAssetDownloadTask(asset: urlAsset, destinationURL: url, options: [AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: 2000000, AVAssetDownloadTaskMediaSelectionKey: mediaSelection])
                }
                
                guard let task = assetDownloadTask else {
                    return
                }
                
                task.taskDescription = asset.name
                
                activeDownloadsMap[task] = asset
                
                task.resume()
                
                userInfo[Stream.Keys.downloadState] = Stream.DownloadState.downloading.rawValue
                userInfo[Stream.Keys.downloadSelectionDisplayName] = mediaSelectionPair.mediaSelectionOption!.displayName
            }
            else {
                // All additional media selections have been downloaded.
                userInfo[Stream.Keys.downloadState] = Stream.DownloadState.downloaded.rawValue
                
            }
        }
        
        NotificationCenter.default.post(name: StreamDownloadStateChangedNotification, object: nil, userInfo: userInfo)
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        let userDefaults = UserDefaults.standard
        
        /*
         This delegate callback should only be used to save the location URL
         somewhere in your application. Any additional work should be done in
         `URLSessionTaskDelegate.urlSession(_:task:didCompleteWithError:)`.
         */
        if let asset = activeDownloadsMap[assetDownloadTask] {
            guard let name = asset.name else { return }
            userDefaults.set(location.relativePath, forKey: name)
        }
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange) {
        // This delegate callback should be used to provide download progress for your AVAssetDownloadTask.
        guard let asset = activeDownloadsMap[assetDownloadTask] else { return }
        
        var percentComplete = 0.0
        for value in loadedTimeRanges {
            let loadedTimeRange : CMTimeRange = value.timeRangeValue
            percentComplete += CMTimeGetSeconds(loadedTimeRange.duration) / CMTimeGetSeconds(timeRangeExpectedToLoad.duration)
        }
        
        var userInfo = [String: Any]()
        userInfo[Stream.Keys.name] = asset.name
        userInfo[Stream.Keys.percentDownloaded] = percentComplete
        
        NotificationCenter.default.post(name: StreamDownloadProgressNotification, object: nil, userInfo:  userInfo)
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didResolve resolvedMediaSelection: AVMediaSelection) {
        /*
         You should be sure to use this delegate callback to keep a reference
         to `resolvedMediaSelection` so that in the future you can use it to
         download additional media selections.
         */
        mediaSelectionMap[assetDownloadTask] = resolvedMediaSelection
    }
}
