//
//  RTAudioViewController.swift
//  LDLARadio
//
//  Created by fox on 15/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Foundation
import UIKit
import SwiftSpinner
import AVKit
import MediaPlayer

class RTAudioViewController : UIViewController {
    
    var controller = RTCatalogController()
    fileprivate var playerViewController: AVPlayerViewController?

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addRefreshControl()
        
        collectionView.remembersLastFocusedIndexPath = true
        
        // Set RadioListTableViewController as the delegate for StreamPlaybackManager to recieve playback information.
        StreamPlaybackManager.sharedManager.delegate = self
    
        
        refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadData()
        
        if playerViewController != nil {
            // The view reappeared as a results of dismissing an AVPlayerViewController.
            // Perform cleanup.
            StreamPlaybackManager.sharedManager.setAssetForPlayback(nil)
            playerViewController?.player = nil
            playerViewController = nil
        }
        

    }
    
    /// Refresh control to allow pull to refresh
    private func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.accessibilityHint = "refresh"
        refreshControl.accessibilityLabel = "refresh"
        refreshControl.addTarget(self, action:
            #selector(RTAudioViewController.handleRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.red
        
        collectionView.addSubview(refreshControl)
        
    }
    
    private func refresh(refreshControl: UIRefreshControl? = nil) {
        
        controller.refresh(startClosure: {
            SwiftSpinner.show(Quote.randomQuote())
            self.reloadData()
            
        }) { (error) in
            refreshControl?.endRefreshing()
            SwiftSpinner.hide()
            self.reloadData()
        }
    }
    
    /// Handler of the pull to refresh, it clears the info container, reload the view and made another request using RestApi
    @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
        refresh(refreshControl: refreshControl)
    }
    
    private func reloadData() {
        collectionView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Commons.segue.player {
            guard let playerViewControler = segue.destination as? AVPlayerViewController else { return }
            
            let model = sender as? AudioViewModel
            
            // Grab a reference for the destinationViewController to use in later delegate callbacks from StreamPlaybackManager.
            playerViewController = playerViewControler
            
            var nowPlayingInfo = [String : Any]()
            nowPlayingInfo[MPMediaItemPropertyTitle] = "Locos de la azotea"
            playerViewControler.title = model?.title
            nowPlayingInfo[MPMediaItemPropertyTitle] = model?.subTitle
            nowPlayingInfo[MPMediaItemPropertyArtist] = model?.detail

            nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = model?.detail
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
            
            if let placeholderImage = UIImage.init(named: "Locos_de_la_azotea") {
                nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork.init(boundsSize: placeholderImage.size) { (size) -> UIImage in
                    return placeholderImage
                }
                
                let iv = UIImageView.init(image: placeholderImage)
                
                if let imageUrl = model?.thumbnailUrl {
                    iv.af_setImage(withURL: imageUrl, placeholderImage: placeholderImage)
                    if  let image = iv.image,
                        let imageCopy = image.copy() as? UIImage {
                        //                        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork.init(image: imageCopy)
                        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork.init(boundsSize: imageCopy.size) { (size) -> UIImage in
                            return imageCopy
                        }
                        
                    }
                }
            }
            
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            
            // Load the new Stream to playback into StreamPlaybackManager.
            StreamPlaybackManager.sharedManager.setAssetForPlayback(model?.urlAsset())

        }
        SwiftSpinner.hide()

    }

}

/**
 Extend `RadioListTableViewController` to conform to the `AssetListTableViewCellDelegate` protocol.
 */
extension RTAudioViewController: AssetListTableViewCellDelegate {
    
    func assetListTableViewCell(_ cell: AudioTableViewCell, downloadStateDidChange newState: Stream.DownloadState) {
    }
}

/**
 Extend `RadioListTableViewController` to conform to the `AssetPlaybackDelegate` protocol.
 */
extension RTAudioViewController: AssetPlaybackDelegate {
    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerReadyToPlay player: AVPlayer) {
        player.play()
    }
    
    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerCurrentItemDidChange player: AVPlayer) {
        guard let playerViewController = playerViewController, player.currentItem != nil else { return }
        
        playerViewController.player = player
    }
}


extension RTAudioViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return controller.mainCatalogViewModel?.audios.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AudioViewModel.hardcode.identifier, for: indexPath) as? AudioCollectionViewCell else { fatalError() }
        cell.model = controller.mainCatalogViewModel?.audios[indexPath.row]
        return cell
    }
    
    
}

extension RTAudioViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        SwiftSpinner.show(Quote.randomQuote())
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? AudioCollectionViewCell else { fatalError() }
        performSegue(withIdentifier: Commons.segue.player, sender: cell.model)
    }
}
