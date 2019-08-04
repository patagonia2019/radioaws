//
//  StreamPlaybackManager.swift
//  LDLARadio
//
//  Created by Javier Fuchs on 1/6/17.
//  Copyright © 2017 Mobile Patagonia. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import JFCore

class StreamPlaybackManager: NSObject {
    // MARK: Properties
    
    /// Singleton for StreamPlaybackManager.
    static let sharedManager = StreamPlaybackManager()
    
    private var observerContext = 0
    
    weak var delegate: AssetPlaybackDelegate?
    
    /// The instance of AVPlayer that will be used for playback of StreamPlaybackManager.playerItem.
    private let player = AVPlayer()
    
    /// A Bool tracking if the AVPlayerItem.status has changed to .readyToPlay for the current StreamPlaybackManager.playerItem.
    private var readyForPlayback = false
    
    /// The AVPlayerItem associated with StreamPlaybackManager.asset.urlAsset
    private var playerItem: AVPlayerItem? {
        willSet {
            if ((playerItem?.observationInfo) != nil) {
                playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: &observerContext)
            }
        }
        
        didSet {
            playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.initial, .new], context: &observerContext)
        }
    }
    
    /// The Stream that is currently being loaded for playback.
    private var urlAsset: AVURLAsset? {
        willSet {
            if ((urlAsset?.observationInfo) != nil) {
                urlAsset?.removeObserver(self, forKeyPath: #keyPath(AVURLAsset.isPlayable), context: &observerContext)
            }
        }
        
        didSet {
            if let urlAsset = urlAsset {
                urlAsset.addObserver(self, forKeyPath: #keyPath(AVURLAsset.isPlayable), options: [.initial, .new], context: &observerContext)
            }
            else {
                playerItem = nil
                player.replaceCurrentItem(with: nil)
                readyForPlayback = false
            }
        }
    }
    
    // MARK: Intitialization
    
    override private init() {
        super.init()
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.multiRoute, options: .mixWithOthers)
            try audioSession.setActive(true)
        }
        catch let error as NSError {
            let error = JFError(code: Int(errno),
                                desc: "Error",
                                reason: "Audio Session failed",
                                suggestion: "Please check the audio in your device",
                                underError: error)
            
            delegate?.streamPlaybackManager(self, playerError: error)
            return
        }

        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem), options: [.new], context: &observerContext)
    }
    
    deinit {
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem))
    }
    
    /**
     Replaces the currently playing `Stream`, if any, with a new `Stream`. If nil
     is passed, `StreamPlaybackManager` will handle unloading the existing `Stream`
     and handle KVO cleanup.
     */
    func setAssetForPlayback(_ urlAsset: AVURLAsset?) {
        self.urlAsset = urlAsset
    }
    
     // MARK: KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &observerContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        guard let keyPath = keyPath else {
            return
        }
        
        switch keyPath {
        case #keyPath(AVURLAsset.isPlayable):
            guard let urlAsset = urlAsset,
                urlAsset.isPlayable == true else {
                    let error = JFError(code: Int(errno),
                                        desc: "Error",
                                        reason: "Player cannot play",
                                        suggestion: "Please check your internet connection",
                                        underError: nil)
                    
                    delegate?.streamPlaybackManager(self, playerError: error)
                    return
            }
            
            playerItem = AVPlayerItem(asset: urlAsset)
            player.replaceCurrentItem(with: playerItem)
        case #keyPath(AVPlayerItem.status):
            guard let playerItem = playerItem else { return }
            if playerItem.status == .readyToPlay {
                if !readyForPlayback {
                    readyForPlayback = true
                    delegate?.streamPlaybackManager(self, playerReadyToPlay: player)
                }
            }
            else if playerItem.status == .failed {
                let error = JFError(code: Int(errno),
                                desc: "Error",
                                reason: "Player failed",
                                suggestion: "Please check your internet connection",
                                underError: playerItem.error as NSError?)

                delegate?.streamPlaybackManager(self, playerError: error)
                return
            }
            
        case #keyPath(AVPlayer.currentItem):
            delegate?.streamPlaybackManager(self, playerCurrentItemDidChange: player)
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

/// AssetPlaybackDelegate provides a common interface for StreamPlaybackManager to provide callbacks to its delegate.
protocol AssetPlaybackDelegate: class {
    
    /// This is called when the internal AVPlayer in StreamPlaybackManager is ready to start playback.
    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerReadyToPlay player: AVPlayer)
    
    /// This is called when the internal AVPlayer's currentItem has changed.
    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerCurrentItemDidChange player: AVPlayer)
    
    /// This is called when the internal AVPlayer in StreamPlaybackManager finds an error.
    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerError error: JFError)

}

