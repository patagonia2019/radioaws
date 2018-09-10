//
//  RadioListTableViewController.swift
//  LDLARadio
//
//  Created by Javier Fuchs on 1/6/17.
//  Copyright © 2017 Mobile Patagonia. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MediaPlayer


class RadioListTableViewController: UITableViewController {
    // MARK: Properties
    
    static let presentPlayerViewControllerSegueIdentifier = "presentPlayerViewControllerSegueIdentifier"
    static let presentWebViewControllerSegueIdentifier = "presentWebViewControllerSegueIdentifier"
    static let presentOgvViewControllerSegueIdentifier = "presentOgvViewControllerSegueIdentifier"
    
    fileprivate var playerViewController: AVPlayerViewController?
    
    // MARK: Deinitialization
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: StreamListManager.didLoadNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: StationListManager.didLoadNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: CityListManager.didLoadNotification, object: nil)
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // General setup for auto sizing UITableViewCells.
        tableView.estimatedRowHeight = 75.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Set RadioListTableViewController as the delegate for StreamPlaybackManager to recieve playback information.
        StreamPlaybackManager.sharedManager.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleStreamListManagerDidLoadNotification(_:)), name: StreamListManager.didLoadNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(handleStreamListManagerDidLoadNotification(_:)), name: StationListManager.didLoadNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(handleStreamListManagerDidLoadNotification(_:)), name: CityListManager.didLoadNotification, object: nil)
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
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StreamListManager.sharedManager.numberOfStreams()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RadioListTableViewCell.reuseIdentifier, for: indexPath)
        
        let stream = StreamListManager.sharedManager.stream(at: indexPath.row)
        if let cell = cell as? RadioListTableViewCell,
            let stationId = stream.station_id,
            let station = StationListManager.sharedManager.station(by: stationId) {
            let city = CityListManager.sharedManager.city(by: station.city_id)
            cell.stream = stream
            cell.station = station
            cell.city = city
            cell.delegate = self
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? RadioListTableViewCell, let station = cell.station,
            let streams = StreamListManager.sharedManager.stream(byStation: station.id),
            let stream = streams.first else { return }
        
        if let use_web = stream.use_web, use_web == true {
            performSegue(withIdentifier: RadioListTableViewController.presentWebViewControllerSegueIdentifier, sender: cell)
            return
        } else {
            performSegue(withIdentifier: RadioListTableViewController.presentPlayerViewControllerSegueIdentifier, sender: cell)
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? RadioListTableViewCell, let asset = cell.stream else { return }
        
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
        
        if segue.identifier == RadioListTableViewController.presentWebViewControllerSegueIdentifier {
            guard let cell = sender as? RadioListTableViewCell,
                let webViewControler = segue.destination as? WebViewController,
                let station = cell.station,
                let stream = cell.stream,
                let city = cell.city,
                let streamLink = stream.name,
                let stationName = station.name,
                let cityName = city.name
                else { return }
            webViewControler.title = "\(stationName) \(cityName)"
            if let source = stream.source_type, source != "" {
                webViewControler.fileName = "LDLARadio.html"
                webViewControler.tokens = [
                    "<RADIO_URL>": streamLink,
                    "<RADIO_TYPE>": source
                ]
            }
            else {
                webViewControler.urlLink = URL(string: streamLink)
            }
            
//        } else if segue.identifier == RadioListTableViewController.presentOgvViewControllerSegueIdentifier {
//            guard let cell = sender as? RadioListTableViewCell,
//                let ogvViewControler = segue.destination as? OGVPlayerViewController,
//                let station = cell.station,
//                let stream = cell.stream,
//                let city = cell.city,
//                let streamLink = stream.name,
//                let stationName = station.name,
//                let cityName = city.name
//                else { return }
//            ogvViewControler.title = "\(stationName) \(cityName)"
//            ogvViewControler.urlLink = URL(string: streamLink)
        }
        else if segue.identifier == RadioListTableViewController.presentPlayerViewControllerSegueIdentifier {
            guard let cell = sender as? RadioListTableViewCell,
                let playerViewControler = segue.destination as? AVPlayerViewController,
                let station = cell.station,
                let city = cell.city
                else { return }
            
            // Grab a reference for the destinationViewController to use in later delegate callbacks from StreamPlaybackManager.
            playerViewController = playerViewControler
            
            var nowPlayingInfo = [String : Any]()
            nowPlayingInfo[MPMediaItemPropertyTitle] = "Locos de la azotea"
            if let stationName = station.name {
                playerViewControler.title = stationName
                nowPlayingInfo[MPMediaItemPropertyTitle] = stationName
                nowPlayingInfo[MPMediaItemPropertyArtist] = stationName
            }
            if let tunning_dial = station.tunning_dial {
                nowPlayingInfo[MPMediaItemPropertyArtist] = tunning_dial
            }
            if let cityName = city.name {
                nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = cityName
            }
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1

            if let placeholderImage = UIImage.init(named: "Locos_de_la_azotea") {
                    nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork.init(image: placeholderImage)

                let iv = UIImageView.init(image: placeholderImage)

                //    public func af_setImage(withURL url: URL, placeholderImage: UIImage? = default, filter: ImageFilter? = default, progress: AlamofireImage.ImageDownloader.ProgressHandler? = default, progressQueue: DispatchQueue = default, imageTransition: UIImageView.ImageTransition = default, runImageTransitionIfCached: Bool = default, completion: ((Alamofire.DataResponse<UIImage>) -> Swift.Void)? = default)

                if let imageUrl = station.imageUrl,
                    let url = URL(string: imageUrl) {
                    iv.af_setImage(withURL: url, placeholderImage: placeholderImage)
                    if  let image = iv.image,
                        let imageCopy = image.copy() as? UIImage {
                        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork.init(image: imageCopy)
                    }
                }
            }

            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo

            // Load the new Stream to playback into StreamPlaybackManager.
            StreamPlaybackManager.sharedManager.setAssetForPlayback(cell.stream)
        }
    }
    
    // MARK: Notification handling
    
    func handleStreamListManagerDidLoadNotification(_: Notification) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

/**
 Extend `RadioListTableViewController` to conform to the `AssetListTableViewCellDelegate` protocol.
 */
extension RadioListTableViewController: AssetListTableViewCellDelegate {
    
    func assetListTableViewCell(_ cell: RadioListTableViewCell, downloadStateDidChange newState: Stream.DownloadState) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

/**
 Extend `RadioListTableViewController` to conform to the `AssetPlaybackDelegate` protocol.
 */
extension RadioListTableViewController: AssetPlaybackDelegate {
    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerReadyToPlay player: AVPlayer) {
        player.play()
    }
    
    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerCurrentItemDidChange player: AVPlayer) {
        guard let playerViewController = playerViewController, player.currentItem != nil else { return }
        
        playerViewController.player = player
    }
}
