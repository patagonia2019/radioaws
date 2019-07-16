//
//  AudioViewController.swift
//  LDLARadio
//
//  Created by Javier Fuchs on 1/6/17.
//  Copyright © 2017 Mobile Patagonia. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MediaPlayer
import SwiftSpinner
import JFCore

class AudioViewController: UITableViewController {
    // MARK: Properties
    
    fileprivate var playerViewController: AVPlayerViewController?
    
    // MARK: Deinitialization
    
    var controller = RTCatalogController()
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        SwiftSpinner.useContainerView(view)

        // Set RadioListTableViewController as the delegate for StreamPlaybackManager to recieve playback information.
        StreamPlaybackManager.sharedManager.delegate = self
        
        addRefreshControl()
        tableView.remembersLastFocusedIndexPath = true

        refresh()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if playerViewController != nil {
            // The view reappeared as a results of dismissing an AVPlayerViewController.
            // Perform cleanup.
            StreamPlaybackManager.sharedManager.setAssetForPlayback(nil)
            playerViewController?.player = nil
            playerViewController = nil
        }
        
        reloadData()

    }
    
    /// Refresh control to allow pull to refresh
    private func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.accessibilityHint = "refresh"
        refreshControl.accessibilityLabel = "refresh"
        refreshControl.addTarget(self, action:
            #selector(AudioViewController.handleRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.red
        
        tableView.addSubview(refreshControl)
        
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
        tableView.reloadData()
    }
    

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        SwiftSpinner.show(Quote.randomQuote())
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? AudioTableViewCell, let asset = cell.stream else { return }
        
        let downloadState = StreamPersistenceManager.sharedManager.downloadState(for: asset)
        let alertAction: UIAlertAction
        
        switch downloadState {
        case .notDownloaded:
            alertAction = UIAlertAction(title: "Download", style: .default) { _ in
                StreamPersistenceManager.sharedManager.downloadStream(for: asset)
            }
            
        case .downloading:
            alertAction = UIAlertAction(title: "Cancel", style: .default) { _ in
                StreamPersistenceManager.sharedManager.cancelDownload(for: asset)
            }
            
        case .downloaded:
            alertAction = UIAlertAction(title: "Delete", style: .default) { _ in
                StreamPersistenceManager.sharedManager.deleteAsset(asset)
            }
        }
        
        let alertController = UIAlertController(title: asset.name, message: "Select from the following options:", preferredStyle: .actionSheet)
        alertController.addAction(alertAction)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            guard let popoverController = alertController.popoverPresentationController else {
                return
            }
            
            popoverController.sourceView = cell
            popoverController.sourceRect = cell.bounds
        }
        
        present(alertController, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == Commons.segue.webView {
            guard let cell = sender as? AudioTableViewCell,
                let webViewControler = segue.destination as? WebViewController,
                let streamLink = cell.stream?.name,
                let stationName = cell.stream?.station?.name,
                let cityName = cell.stream?.station?.city?.name
                else { return }
            webViewControler.title = "\(stationName) \(cityName)"
            if let source = cell.stream?.sourceType, source != "" {
                webViewControler.fileName = "LDLARadio.html"
                webViewControler.tokens = [
                    "<RADIO_URL>": streamLink,
                    "<RADIO_TYPE>": source
                ]
            }
            else {
                webViewControler.urlLink = URL(string: streamLink)
            }
        }
        else if segue.identifier == Commons.segue.player {
            guard let model = sender as? AudioViewModel,
                let playerViewControler = segue.destination as? AVPlayerViewController else { return }
            
            // Grab a reference for the destinationViewController to use in later delegate callbacks from StreamPlaybackManager.
            playerViewController = playerViewControler
            
            
            var nowPlayingInfo = [String : Any]()
            nowPlayingInfo[MPMediaItemPropertyTitle] = "Locos de la azotea"
            playerViewControler.title = model.title
            nowPlayingInfo[MPMediaItemPropertyTitle] = model.subTitle
            nowPlayingInfo[MPMediaItemPropertyArtist] = model.detail
            
            nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = model.detail
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1


            if let placeholderImage = UIImage.init(named: "Locos_de_la_azotea") {
                nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork.init(boundsSize: placeholderImage.size) { (size) -> UIImage in
                    return placeholderImage
                }

                let iv = UIImageView.init(image: placeholderImage)

                if let imageUrl = model.thumbnailUrl {
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
            StreamPlaybackManager.sharedManager.setAssetForPlayback(model.urlAsset())
        }
        SwiftSpinner.hide()
    }
}

/**
 Extend `AudioViewController` to conform to the `AssetListTableViewCellDelegate` protocol.
 */
extension AudioViewController: AssetListTableViewCellDelegate {
    
    func assetListTableViewCell(_ cell: AudioTableViewCell, downloadStateDidChange newState: Stream.DownloadState) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

/**
 Extend `AudioViewController` to conform to the `AssetPlaybackDelegate` protocol.
 */
extension AudioViewController: AssetPlaybackDelegate {
    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerReadyToPlay player: AVPlayer) {
        player.play()
    }
    
    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerCurrentItemDidChange player: AVPlayer) {
        guard let playerViewController = playerViewController, player.currentItem != nil else { return }
        
        playerViewController.player = player
    }
}

extension AudioViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = controller.mainCatalogViewModel?.audios[indexPath.row]
        if model?.useWeb ?? false {
            performSegue(withIdentifier: Commons.segue.webView, sender: model)
        } else {
            performSegue(withIdentifier: Commons.segue.player, sender: model)
        }
    }
}

extension AudioViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller.mainCatalogViewModel?.audios.count ?? 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return controller.mainCatalogViewModel?.title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AudioTableViewCell.reuseIdentifier, for: indexPath) as? AudioTableViewCell else { fatalError() }
        
        cell.model = controller.mainCatalogViewModel?.audios[indexPath.row]
        cell.delegate = self
        
        return cell
    }
    
}

