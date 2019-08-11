//
//  AudioViewController.swift
//  LDLARadio
//
//  Created by fox on 22/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MediaPlayer
import SwiftSpinner
import JFCore

class AudioViewController: UITableViewController {
    // MARK: Properties
    
    var isFullScreen : Bool = false
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    var radioController = RadioController()
    var radioTimeController = RadioTimeController()
    var rnaController = RNAController()
    var bookmarkController = BookmarkController()
    var desconciertoController = ElDesconciertoController()
    var searchController = SearchController()

    var controller: BaseController {
        get {
            let title = titleForController()
            switch title {
                case AudioViewModel.ControllerName.suggestion.rawValue:
                    return radioController
                case AudioViewModel.ControllerName.radioTime.rawValue:
                    return radioTimeController
                case AudioViewModel.ControllerName.rna.rawValue:
                    return rnaController
                case AudioViewModel.ControllerName.bookmark.rawValue:
                    return bookmarkController
                case AudioViewModel.ControllerName.desconcierto.rawValue:
                    return desconciertoController
                case AudioViewModel.ControllerName.search.rawValue:
                    return searchController
                default:
                    fatalError()
                }
        }
        set {
            let title = titleForController()

            switch title {
            case AudioViewModel.ControllerName.suggestion.rawValue:
                radioController = newValue as! RadioController
                break
            case AudioViewModel.ControllerName.radioTime.rawValue:
                radioTimeController = newValue as! RadioTimeController
                break
            case AudioViewModel.ControllerName.rna.rawValue:
                rnaController = newValue as! RNAController
                break
            case AudioViewModel.ControllerName.bookmark.rawValue:
                bookmarkController = newValue as! BookmarkController
                break
            case AudioViewModel.ControllerName.desconcierto.rawValue:
                desconciertoController = newValue as! ElDesconciertoController
                break
            case AudioViewModel.ControllerName.search.rawValue:
                searchController = newValue as! SearchController
                break
            default:
                fatalError()
            }
        }
    }
    
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftSpinner.useContainerView(view)
        
        refreshButton.isEnabled = controller.useRefresh
        
        // Set the ViewController as the delegate for StreamPlaybackManager to recieve playback information.
        StreamPlaybackManager.sharedManager.delegate = self
        
        if controller.useRefresh {
            addRefreshControl()
        }
        tableView.remembersLastFocusedIndexPath = true
        HeaderTableView.setup(tableView: tableView)

        if (controller is SearchController) {
            refresh(isClean: true)
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        if !(controller is SearchController) {            
            refresh()
        }
        else {
            reloadData()
        }
    }
    
    private func titleForController() -> String? {
        let titleName = self.tabBarItem.title ?? self.navigationController?.tabBarItem.title ??  self.tabBarController?.selectedViewController?.tabBarItem.title
        return titleName
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
    
    func refresh(isClean: Bool = false, refreshControl: UIRefreshControl? = nil) {
        
        controller.refresh(isClean: isClean, prompt: "",
                           startClosure: {
                            SwiftSpinner.show(Quote.randomQuote())
        }) { (error) in
            if let error = error {
                self.showAlert(error: error)
                Analytics.logError(error: error)
            }
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
        if let navigationBar = self.navigationController?.navigationBar,
            let tabBar = self.navigationController?.tabBarController?.tabBar ??
            self.tabBarController?.tabBar {
            
            if isFullScreen {
                navigationBar.isHidden = true
                tabBar.isHidden = true
            }
            else {
                navigationBar.isHidden = false
                tabBar.isHidden = false
            }
        }
    }
    
    private func bookmark(indexPath: IndexPath, isReload: Bool = true) {
        let object = self.controller.model(forSection: indexPath.section, row: indexPath.row)
        if let audio = object as? AudioViewModel {
            controller.changeAudioBookmark(model: audio)
            audio.isBookmarked = !(audio.isBookmarked ?? false)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
        if let section = object as? CatalogViewModel {
            self.controller.changeCatalogBookmark(model: section)
        }
    }
    
    private func play(indexPath: IndexPath, isReload: Bool = true) {
        let object = controller.model(forSection: indexPath.section, row: indexPath.row)
        if let audio = object as? AudioViewModel {
            Analytics.logFunction(function: "embeddedplay",
                                  parameters: ["audio": audio.title.text as AnyObject,
                                               "section": audio.section as AnyObject,
                                               "url": audio.urlString() as AnyObject,
                                               "controller": titleForController() as AnyObject])
            controller.play(forSection: indexPath.section, row: indexPath.row)
            if audio.isPlaying {
                StreamPlaybackManager.sharedManager.setAssetForPlayback(audio)
            }
            else {
                StreamPlaybackManager.sharedManager.pause()
            }
            self.reloadData()
            UIView.animate(withDuration: 0.5, animations: {
            }) { (finished) in
                if finished {
                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                }
            }
        }
        else if let section = object as? CatalogViewModel {
            performSegue(withIdentifier: Commons.segue.catalog, sender: section)
        }

    }
    
    private func expand(model: CatalogViewModel?, section: Int) {
        // Reusing the same model, but focus in this section
        if controller is RadioTimeController {
            (controller as? RadioTimeController)?.expand(model: model, section: section, startClosure: {
                RestApi.instance.context?.performAndWait {
                    SwiftSpinner.show(Quote.randomQuote())
                }
            }, finishClosure: { (error) in
                if let error = error {
                    self.showAlert(error: error)
                    Analytics.logError(error: error)
                }
                SwiftSpinner.hide()
                self.reloadData()
            })
        }
        else if controller is ElDesconciertoController {
            (controller as? ElDesconciertoController)?.expand(model: model, section: section, finishClosure: { (error) in
                self.reloadData()
            })
        }
    }
    
    /// Handler of the pull to refresh, it clears the info container, reload the view and made another request using RestApi
    @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
        Analytics.logFunction(function: "refresh",
                              parameters: ["method": "control" as AnyObject,
                                           "controller": titleForController() as AnyObject])

        refresh(isClean: true, refreshControl: refreshControl)
    }
    
    @IBAction func shareAction(_ sender: Any) {
        share(indexPath: nil, controller: controller, tableView: tableView)
    }

    @IBAction func refreshAction(_ sender: Any) {
        refresh(isClean: true)
    }
    
    @IBAction func searchAction(_ sender: Any) {
        
        let alert = UIAlertController(title: "Search", message: "What do you need to search?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField { (textfield) in
            textfield.placeholder = "Search"
            textfield.text = (self.controller as? SearchController)?.textToSearch
            textfield.autocorrectionType = .no
            textfield.autocapitalizationType = .none
        }
        let search = UIAlertAction.init(title: "Search", style: .default) { action in
            guard let textToSearch = alert.textFields?[0],
                let text = textToSearch.text,
                text.count > 0 else {
                return
            }
            if self.controller is SearchController {
                (self.controller as? SearchController)?.textToSearch = text
                self.refresh(isClean: true)
            }
            else {
                self.performSegue(withIdentifier: Commons.segue.search, sender: text)
            }
        }
        alert.addAction(search)
        self.present(alert, animated: true, completion: nil)
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderTableView.reuseIdentifier) as? HeaderTableView
        if controller is RadioTimeController {
            headerView?.actionExpandBlock = { model, isHighlighted in
                self.expand(model:model, section:section)
            }
            headerView?.actionBookmarkBlock = { model, isHighlighted in
                (self.controller as? RadioTimeController)?.changeCatalogBookmark(section: section)
            }
            headerView?.model = (controller as? RadioTimeController)?.modelInstance(inSection: section)
            return headerView
        }
        else if controller is ElDesconciertoController {
            headerView?.actionExpandBlock = { model, isHighlighted in
                self.expand(model:model, section:section)
            }
            headerView?.actionBookmarkBlock = { model, isHighlighted in
                (self.controller as? ElDesconciertoController)?.changeCatalogBookmark(section: section)
            }
            headerView?.model = (controller as? ElDesconciertoController)?.model(inSection: section)
            return headerView
        }
        return nil
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

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var actions = [UITableViewRowAction]()
        
        let object = controller.model(forSection: indexPath.section, row: indexPath.row)
        var isBookmarked : Bool? = false
        if let audio = object as? AudioViewModel {
            let playAction = UITableViewRowAction(style: .normal, title: audio.isPlaying ? "Pause" : "Play") { (action, indexPath) in
                self.play(indexPath: indexPath)
            }
            playAction.backgroundColor = audio.isPlaying ? .red : .green
            actions.append(playAction)
            
            isBookmarked = audio.isBookmarked
        }

        if let section = object as? CatalogViewModel {
            isBookmarked = section.isBookmarked
        }
        if let isBookmarked = isBookmarked {
            let bookmarkAction = UITableViewRowAction(style: .destructive, title: isBookmarked ? "Delete" : "Add") { (action, indexPath) in
                self.bookmark(indexPath: indexPath)
            }
            bookmarkAction.backgroundColor = isBookmarked ? .purple : .blue
            actions.append(bookmarkAction)
        }
        
        let shareAction = UITableViewRowAction(style: .normal, title: "Share") { (action, indexPath) in
            self.share(indexPath: indexPath, controller: self.controller, tableView: self.tableView)
        }
        shareAction.backgroundColor = .orange
        actions.append(shareAction)
        
        return actions
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = controller.model(forSection: indexPath.section, row: indexPath.row)
        if let audio = object as? AudioViewModel {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AudioTableViewCell.reuseIdentifier, for: indexPath) as? AudioTableViewCell else { fatalError() }
            cell.delegate = self
            cell.model = audio
            return cell
        }
        if let section = object as? CatalogViewModel {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CatalogTableViewCell.reuseIdentifier, for: indexPath) as? CatalogTableViewCell else { fatalError() }
            cell.model = section
            cell.actionBookmarkBlock = { catalog, isBookmarking in
                self.controller.changeCatalogBookmark(at: indexPath.section, row: indexPath.row)
            }
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CatalogTableViewCell.reuseIdentifier, for: indexPath) as? CatalogTableViewCell else { fatalError() }
        cell.model = nil
        if controller is BookmarkController {
            cell.detailTextLabel?.text = "You should tap on the Apple button to get some."
        }
        else if controller is SearchController {
            cell.detailTextLabel?.text = "Please try again with another search term."
        }
        return cell
    }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        play(indexPath: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Commons.segue.catalog {
            segue.destination.tabBarItem.title = AudioViewModel.ControllerName.radioTime.rawValue
            (segue.destination as? AudioViewController)?.controller = RadioTimeController(withCatalogViewModel: (sender as? CatalogViewModel))
        }
        else if segue.identifier == Commons.segue.search {
            segue.destination.tabBarItem.title = AudioViewModel.ControllerName.search.rawValue
            (segue.destination as? AudioViewController)?.controller = SearchController(withText: (sender as? String))
        }
        SwiftSpinner.hide()
    }
    
}

/**
 Extend `AudioViewController` to conform to the `AudioTableViewCellDelegate` protocol.
 */
extension AudioViewController: AudioTableViewCellDelegate {
    
    func audioTableViewCell(_ cell: AudioTableViewCell, bookmarkDidChange newState: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        bookmark(indexPath: indexPath)
    }
    
    
    func audioTableViewCell(_ cell: AudioTableViewCell, downloadStateDidChange newState: Stream.DownloadState) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func audioTableViewCell(_ cell: AudioTableViewCell, didPlay newState: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        play(indexPath: indexPath)
    }
    
    func audioTableViewCell(_ cell: AudioTableViewCell, didResize newState: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let object = controller.model(forSection: indexPath.section, row: indexPath.row)
        if let audio = object as? AudioViewModel {
            Analytics.logFunction(function: "resize",
                                  parameters: ["audio": audio.title.text as AnyObject,
                                               "isPlaying": audio.isPlaying as AnyObject,
                                               "didResize": newState as AnyObject,
                                               "url": audio.urlString() as AnyObject,
                                               "controller": titleForController() as AnyObject])
            isFullScreen = audio.isFullScreen
            reloadData()
        }

    }

    func audioTableViewCell(_ cell: AudioTableViewCell, didChangeTargetSound newState: Bool) {
        
    }
    
    func audioTableViewCell(_ cell: AudioTableViewCell, didChangeToEnd toEnd: Bool) {
        StreamPlaybackManager.sharedManager.seekEnd()
    }

    func audioTableViewCell(_ cell: AudioTableViewCell, didChangeOffset isBackward: Bool) {
        if isBackward {
            StreamPlaybackManager.sharedManager.backward()
        }
        else {
            StreamPlaybackManager.sharedManager.forward()
        }
    }

    func audioTableViewCell(_ cell: AudioTableViewCell, didChangePosition newValue: Float) {
        StreamPlaybackManager.sharedManager.playPosition(position: Double(newValue))
    }
    
    func audioTableViewCell(_ cell: AudioTableViewCell, didShowInfo newValue: Bool) {
        
    }
    
    func audioTableViewCell(_ cell: AudioTableViewCell, didShowBug newValue: Bool) {
        
    }

    func audioTableViewCell(_ cell: AudioTableViewCell, didShowGraph newValue: Bool) {
        
    }
    
    
}

/**
 Extend `AudioViewController` to conform to the `AssetPlaybackDelegate` protocol.
 */
extension AudioViewController: AssetPlaybackDelegate {
    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerError error: JFError) {
        Analytics.logError(error: error)
        showAlert(error: error)
    }
    
    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerReadyToPlay player: AVPlayer, isPlaying: Bool) {
        if isPlaying {
            print("JF FINALLY PLAYING")
            player.play()
        }
        else {
            print("JF PAUSE")
            player.pause()
        }
        reloadData()
    }
    
    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerCurrentItemDidChange player: AVPlayer) {
        print("JF CHANGE")
        reloadData()
        player.play()
    }
}

