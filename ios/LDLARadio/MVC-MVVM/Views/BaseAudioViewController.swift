//
//  BaseAudioViewController.swift
//  LDLARadio
//
//  Created by fox on 22/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MediaPlayer
import SwiftSpinner
import JFCore

class BaseAudioViewController: UITableViewController {
    // MARK: Properties
    
    var controller = BaseController()
    var playerViewController: AVPlayerViewController?
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftSpinner.useContainerView(view)
        
        // Set the ViewController as the delegate for StreamPlaybackManager to recieve playback information.
        StreamPlaybackManager.sharedManager.delegate = self
        
        if controller.useRefresh {
            addRefreshControl()
        }
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
        
        refresh()
        
    }
    
    /// Refresh control to allow pull to refresh
    private func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.accessibilityHint = "refresh"
        refreshControl.accessibilityLabel = "refresh"
        refreshControl.addTarget(self, action:
            #selector(BaseAudioViewController.handleRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.red
        
        tableView.addSubview(refreshControl)
        
    }
    
    func refresh(isClean: Bool = false, refreshControl: UIRefreshControl? = nil) {
        
        controller.refresh(isClean: isClean, prompt: "",
                           startClosure: {
                            RestApi.instance.context?.performAndWait {
                                SwiftSpinner.show(Quote.randomQuote())
                            }
                            self.reloadData()
                            
        }) { (error) in
            refreshControl?.endRefreshing()
            SwiftSpinner.hide()
            self.reloadData()
        }
    }
    
    private func reloadData() {
        tableView.refreshControl?.attributedTitle = controller.title().bigRed()
        navigationItem.prompt = controller.prompt()
        navigationItem.title = controller.title()
        tableView.reloadData()
    }
    
    private func play(indexPath: IndexPath) {
        let object = controller.model(forSection: indexPath.section, row: indexPath.row)
        if let audio = object as? AudioViewModel {
            if audio.useWeb {
                performSegue(withIdentifier: Commons.segue.webView, sender: audio)
            } else {
                performSegue(withIdentifier: Commons.segue.player, sender: audio)
            }
        }
        if let section = object as? CatalogViewModel {
            performSegue(withIdentifier: Commons.segue.catalog, sender: section)
        }

    }
    
    /// Handler of the pull to refresh, it clears the info container, reload the view and made another request using RestApi
    @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
        refresh(isClean: true, refreshControl: refreshControl)
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return controller.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller.numberOfRows(inSection: section)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return controller.titleForHeader(inSection: section)
    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return controller.heightForRow(at: indexPath.section, row: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return controller.heightForHeader(at: section)
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let object = controller.model(forSection: indexPath.section, row: indexPath.row)
        if object is AudioViewModel {
            return indexPath
        }
        if let section = object as? CatalogViewModel {
            if section.selectionStyle == .none {
                return nil
            }
        }
        return indexPath
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = controller.model(forSection: indexPath.section, row: indexPath.row)
        if let audio = object as? AudioViewModel {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AudioViewModel.hardcode.identifier, for: indexPath) as? AudioTableViewCell else { fatalError() }
            cell.delegate = self
            cell.model = audio
            return cell
        }
        if let section = object as? CatalogViewModel {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CatalogViewModel.hardcode.identifier, for: indexPath) as? CatalogTableViewCell else { fatalError() }
            cell.model = section
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CatalogViewModel.hardcode.identifier, for: indexPath) as? CatalogTableViewCell else { fatalError() }
        return cell
    }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        play(indexPath: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Commons.segue.catalog {
            (segue.destination as? RadioTimeViewController)?.controller = RadioTimeController(withCatalogViewModel: (sender as? CatalogViewModel))
        }
        else if segue.identifier == Commons.segue.webView {
            guard let model = sender as? AudioViewModel,
                let webViewControler = segue.destination as? WebViewController,
                let streamLink = model.url
                else { return }
            webViewControler.title = "\(model.title) \(model.subTitle)"
            webViewControler.urlLink = streamLink
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
 Extend `BaseAudioViewController` to conform to the `AudioTableViewCellDelegate` protocol.
 */
extension BaseAudioViewController: AudioTableViewCellDelegate {
    func audioTableViewCell(_ cell: AudioTableViewCell, didPlay newState: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        play(indexPath: indexPath)
    }
    
    func audioTableViewCell(_ cell: AudioTableViewCell, bookmarkDidChange newState: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        tableView.reloadRows(at: [indexPath], with: .none)
        controller.changeBookmark(at: indexPath.section, row: indexPath.row)
    }
    
    
    func audioTableViewCell(_ cell: AudioTableViewCell, downloadStateDidChange newState: Stream.DownloadState) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

/**
 Extend `BaseAudioViewController` to conform to the `AssetPlaybackDelegate` protocol.
 */
extension BaseAudioViewController: AssetPlaybackDelegate {
    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerReadyToPlay player: AVPlayer) {
        player.play()
    }
    
    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerCurrentItemDidChange player: AVPlayer) {
        guard let playerViewController = playerViewController, player.currentItem != nil else { return }
        
        playerViewController.player = player
    }
}
