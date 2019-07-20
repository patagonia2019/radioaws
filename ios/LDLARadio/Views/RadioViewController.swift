//
//  RadioViewController.swift
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

class RadioViewController: UITableViewController {
    // MARK: Properties
    
    fileprivate var playerViewController: AVPlayerViewController?
    
    // MARK: Deinitialization
    
    private var streams = /* StreamListManager.instance.streamsFetch() ?? */ [Stream]()

    deinit {
        for note in [StreamListManager.didLoadNotification, StationListManager.didLoadNotification, CityListManager.didLoadNotification] {
            NotificationCenter.default.removeObserver(self, name: note, object: nil)
        }
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        SwiftSpinner.useContainerView(view)

        // Set RadioListTableViewController as the delegate for StreamPlaybackManager to recieve playback information.
        StreamPlaybackManager.sharedManager.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleStreamListManagerDidLoadNotification(_:)), name: StreamListManager.didLoadNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(handleStationListManagerDidLoadNotification(_:)), name: StationListManager.didLoadNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(handleCityListManagerDidLoadNotification(_:)), name: CityListManager.didLoadNotification, object: nil)
        
        addRefreshControl()
        tableView.remembersLastFocusedIndexPath = true

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
        
        tableView.reloadData()
        
    }
    
    /// Refresh control to allow pull to refresh
    private func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.accessibilityHint = "refresh"
        refreshControl.accessibilityLabel = "refresh"
        refreshControl.addTarget(self, action:
            #selector(RadioViewController.handleRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.red
        
        tableView.addSubview(refreshControl)
        
    }

    /// Handler of the pull to refresh, it clears the info container, reload the view and made another request using RestApi
    @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
        streams = [Stream]()
        SwiftSpinner.show(Quote.randomQuote())
        tableView.reloadData()
        StreamListManager.instance.clean()
        StationListManager.instance.clean()
        CityListManager.instance.clean()
        
        StreamListManager.instance.setup { (error) in
            if error != nil {
                CoreDataManager.instance.rollback()
            }
            else {
                CoreDataManager.instance.save()
            }
            self.streams = StreamListManager.instance.streamsFetch() ?? [Stream]()
            DispatchQueue.main.async {
                refreshControl.endRefreshing()
                SwiftSpinner.hide()
                self.tableView.reloadData()
            }
        }
        
    }

    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return streams.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AudioTableViewCell.reuseIdentifier, for: indexPath) as? AudioTableViewCell else { fatalError() }
        
        if indexPath.row < streams.count {
            let stream = streams[indexPath.row]
            cell.stream = stream
            cell.delegate = self
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        SwiftSpinner.show(Quote.randomQuote())
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? AudioTableViewCell,
            let stream = cell.stream else { return }
        
        if stream.useWeb {
            performSegue(withIdentifier: Commons.segue.webView, sender: cell)
            return
        } else {
            performSegue(withIdentifier: Commons.segue.player, sender: cell)
        }
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
            guard let cell = sender as? AudioTableViewCell,
                let playerViewControler = segue.destination as? AVPlayerViewController else { return }
            
            // Grab a reference for the destinationViewController to use in later delegate callbacks from StreamPlaybackManager.
            playerViewController = playerViewControler
            
            var nowPlayingInfo = [String : Any]()
            nowPlayingInfo[MPMediaItemPropertyTitle] = "Locos de la azotea"
            if let stationName = cell.stream?.station?.name {
                playerViewControler.title = stationName
                nowPlayingInfo[MPMediaItemPropertyTitle] = stationName
                nowPlayingInfo[MPMediaItemPropertyArtist] = stationName
            }
            nowPlayingInfo[MPMediaItemPropertyArtist] = cell.stream?.station?.tuningDial
            nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = cell.stream?.station?.city?.name
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1

            if let placeholderImage = UIImage.init(named: "Locos_de_la_azotea") {
                nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork.init(boundsSize: placeholderImage.size) { (size) -> UIImage in
                    return placeholderImage
                }

                let iv = UIImageView.init(image: placeholderImage)

                if let imageUrl = cell.stream?.station?.imageUrl,
                    let url = URL(string: imageUrl) {
                    iv.af_setImage(withURL: url, placeholderImage: placeholderImage)
                    if  let image = iv.image,
                        let imageCopy = image.copy() as? UIImage {
                        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork.init(boundsSize: imageCopy.size) { (size) -> UIImage in
                            return imageCopy
                        }

                    }
                }
            }

            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo

            // Load the new Stream to playback into StreamPlaybackManager.
            StreamPlaybackManager.sharedManager.setAssetForPlayback(cell.stream?.urlAsset())
        }
        SwiftSpinner.hide()
    }
    
    /// MARK: Notification handling
    
    @objc func handleStreamListManagerDidLoadNotification(_: Notification) {
        DispatchQueue.main.async {
            StreamListManager.instance.update()
            self.streams = StreamListManager.instance.streamsFetch() ?? [Stream]()
            self.tableView.reloadData()
        }
    }
    
    @objc func handleCityListManagerDidLoadNotification(_: Notification) {
        DispatchQueue.main.async {
            CityListManager.instance.update()
            self.tableView.reloadData()
        }
    }

    @objc func handleStationListManagerDidLoadNotification(_: Notification) {
        DispatchQueue.main.async {
            StationListManager.instance.update()
            self.tableView.reloadData()
        }
    }
}

/**
 Extend `RadioListTableViewController` to conform to the `AssetListTableViewCellDelegate` protocol.
 */
extension RadioViewController: AssetListTableViewCellDelegate {
    
    func assetListTableViewCell(_ cell: AudioTableViewCell, downloadStateDidChange newState: Stream.DownloadState) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

/**
 Extend `RadioListTableViewController` to conform to the `AssetPlaybackDelegate` protocol.
 */
extension RadioViewController: AssetPlaybackDelegate {
    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerReadyToPlay player: AVPlayer) {
        player.play()
    }
    
    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerCurrentItemDidChange player: AVPlayer) {
        guard let playerViewController = playerViewController, player.currentItem != nil else { return }
        
        playerViewController.player = player
    }
}
