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

    var isFullScreen: Bool = false
    var currentPlayIndexPath: IndexPath?
    var lastTitleName: String = AudioViewModel.ControllerName.suggestion.rawValue
    fileprivate var timerPlayed: Timer?

    @IBOutlet weak var refreshButton: UIBarButtonItem!

    var radioController = RadioController()
    var radioTimeController = RadioTimeController()
    var rnaController = RNAController()
    var bookmarkController = BookmarkController()
    var desconciertoController = ElDesconciertoController()
    var searchController = SearchController()
    var archiveOrgController = ArchiveOrgController()
    var archiveOrgMainModelController = ArchiveOrgMainModelController()

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
            case AudioViewModel.ControllerName.archiveOrg.rawValue:
                return archiveOrgController
            case AudioViewModel.ControllerName.archiveMainModelOrg.rawValue:
                return archiveOrgMainModelController
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
                if let newValue = newValue as? RadioController {
                    radioController = newValue
                }
            case AudioViewModel.ControllerName.radioTime.rawValue:
                if let newValue = newValue as? RadioTimeController {
                    radioTimeController = newValue
                }
            case AudioViewModel.ControllerName.rna.rawValue:
                if let newValue = newValue as? RNAController {
                    rnaController = newValue
                }
            case AudioViewModel.ControllerName.bookmark.rawValue:
                if let newValue = newValue as? BookmarkController {
                    bookmarkController = newValue
                }
            case AudioViewModel.ControllerName.desconcierto.rawValue:
                if let newValue = newValue as? ElDesconciertoController {
                    desconciertoController = newValue
                }
            case AudioViewModel.ControllerName.archiveOrg.rawValue:
                if let newValue = newValue as? ArchiveOrgController {
                    archiveOrgController = newValue
                }
            case AudioViewModel.ControllerName.archiveMainModelOrg.rawValue:
                if let newValue = newValue as? ArchiveOrgMainModelController {
                    archiveOrgMainModelController = newValue
                }
            case AudioViewModel.ControllerName.search.rawValue:
                if let newValue = newValue as? SearchController {
                    searchController = newValue
                }
            default:
                fatalError()
            }
        }
    }

    // MARK: UIViewController
    deinit {
        let stream = StreamPlaybackManager.instance
        stream.delegate = nil
        stream.delegate2 = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let stream = StreamPlaybackManager.instance
        stream.delegate2 = self
        SwiftSpinner.useContainerView(view)

        refreshButton.isEnabled = controller.useRefresh

        if controller.useRefresh {
            addRefreshControl()
        }
        tableView.remembersLastFocusedIndexPath = true

        HeaderTableView.setup(tableView: tableView)

        if controller is SearchController {
            refresh(isClean: true)
        }

        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)

        navigationController?.setToolbarHidden(true, animated: false)

        if let toolbar = navigationController?.toolbar {
            toolbar.isHidden = true
            let stream = StreamPlaybackManager.instance
            stream.delegate = toolbar
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if controller is BookmarkController {
            navigationItem.leftBarButtonItems = [trashButton]
        } else {
            navigationItem.leftBarButtonItems = nil
        }
        updateNavBar()

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let timerPlayed = timerPlayed {
            timerPlayed.invalidate()
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !(controller is SearchController) {
            refresh()
        } else {
            reloadData()
        }
        updateNavBar()
    }

    private func titleForController() -> String? {
        if !Thread.isMainThread {
            Log.error("NOT Main Thread")
            return lastTitleName
        }

        lastTitleName = self.tabBarItem.title ?? self.navigationController?.tabBarItem.title ?? self.tabBarController?.selectedViewController?.tabBarItem.title ?? lastTitleName
        return lastTitleName
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

    lazy var trashButton: UIBarButtonItem = {
        let trash = UIButton(type: .custom)
        trash.addTarget(self, action: #selector(AudioViewController.trashAction(_:)), for: .touchUpInside)
        trash.heightAnchor.constraint(equalToConstant: Commons.Size.toolbarButtonFontSize).isActive = true
        trash.widthAnchor.constraint(equalToConstant: Commons.Size.toolbarButtonFontSize).isActive = true
        trash.frame.size = CGSize(width: Commons.Size.toolbarButtonFontSize, height: Commons.Size.toolbarButtonFontSize)
        guard let font = UIFont(name: Commons.Font.awesome, size: 30) else {
            fatalError()
        }
        trash.setTitleColor(.maraschino, for: .normal)
        trash.setTitleColor(.steel, for: .highlighted)
        trash.titleLabel?.font = font
        trash.setTitle("\(Commons.Symbol.showAwesome(icon: .trash))", for: .normal)

        let button = UIBarButtonItem(customView: trash)
        return button
    }()

    func refresh(isClean: Bool = false, refreshControl: UIRefreshControl? = nil) {

        controller.refresh(isClean: isClean, prompt: "",
                           startClosure: {
                            SwiftSpinner.show(Quote.randomQuote())
        }, finishClosure: { (error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(error: error)
                }
                Analytics.logError(error: error)
            }
            refreshControl?.endRefreshing()
            SwiftSpinner.hide()
            self.reloadData()
        })
    }

    func updateNavBar() {
        navigationItem.prompt = " "
        for view in navigationController?.navigationBar.subviews ?? [] where NSStringFromClass(view.classForCoder) == "_UINavigationBarModernPromptView" {
            if let prompt = view.subviews.first as? UILabel {
                prompt.text = controller.prompt()
                prompt.textColor = .midnight
                let font = UIFont(name: Commons.Font.bold, size: 20)
                prompt.font = font
            }
        }
        navigationItem.title = controller.title()
    }

    private func reloadData(_ section: Int? = nil, _ row: Int? = nil) {
        if !Thread.isMainThread {
            Log.fault("fatal error is not Main Thread")
            fatalError()
        }
        tableView.refreshControl?.attributedTitle = controller.title().bigRed()
        updateNavBar()
        if let section = section, let row = row {
            tableView.beginUpdates()
            tableView.reloadRows(at: [IndexPath(row: row, section: section)], with: .fade)
            tableView.endUpdates()
        } else if let section = section {
            tableView.beginUpdates()
            tableView.reloadSections(IndexSet(integer: section), with: .fade)
            tableView.endUpdates()
        } else {
            tableView.reloadData()
        }
        
//        reloadTimer()
    }

//    private func reloadTimer() {
//
//        let stream = StreamPlaybackManager.instance
//
//        if let timerPlayed = timerPlayed {
//            timerPlayed.invalidate()
//        }
//
//        if stream.isAboutToPlay() {
//            timerPlayed = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(reloadToolbar), userInfo: nil, repeats: true)
//        } else {
//            guard let toolbar = navigationController?.toolbar else { return }
//            navigationController?.setToolbarHidden(true, animated: false)
//            toolbar.isHidden = true
//        }
//    }

    @objc private func reloadToolbar() {

        guard let toolbar = navigationController?.toolbar else { return }
        navigationController?.setToolbarHidden(false, animated: false)
        toolbar.isHidden = false
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseInOut, animations: {
            if var rect = self.tabBarController?.tabBar.frame {
                rect.origin.y -= rect.size.height
                toolbar.frame = rect
            }
        }, completion: { _ in
            toolbar.setNeedsLayout()
            toolbar.setNeedsDisplay()
        })
    }

    private func info(model: SectionViewModel?) {
        showAlert(title: model?.title.text, message: model?.text, error: nil)
    }

    private func info(indexPath: IndexPath) {
        let object = controller.model(forSection: indexPath.section, row: indexPath.row)
        if let audio = object as? AudioViewModel {
            showAlert(title: audio.title.text, message: audio.info, error: nil)
        } else if let section = object as? SectionViewModel {
            info(model: section)
        }
    }

    private func play(indexPath: IndexPath, isReload: Bool = true) {
        let object = controller.model(forSection: indexPath.section, row: indexPath.row)
        if object is AudioViewModel {
            DispatchQueue.main.async {
                if (object as? AudioViewModel) != nil {
                    self.currentPlayIndexPath = indexPath
                    self.reloadData(indexPath.section, indexPath.row)
                }
                DispatchQueue.global(qos: .background).async {
                    self.controller.play(forSection: indexPath.section, row: indexPath.row)
                    DispatchQueue.main.async {
                        self.reloadData(indexPath.section)
                    }
                }
            }
        } else if let section = object as? SectionViewModel {
            if controller is RadioTimeController {
                performSegue(withIdentifier: Commons.Segue.catalog, sender: section)
            } else if controller is ArchiveOrgController {
                performSegue(withIdentifier: Commons.Segue.archiveorg, sender: section)
            } else if controller is SearchController {
                if section.section == AudioViewModel.ControllerName.radioTime.rawValue {
                    performSegue(withIdentifier: Commons.Segue.catalog, sender: section)
                } else if section.section == AudioViewModel.ControllerName.archiveOrg.rawValue {
                    performSegue(withIdentifier: Commons.Segue.archiveorg, sender: section)
                }
            }
        } else {
            if controller is ArchiveOrgController || controller is SearchController {
                if let cell = tableView.cellForRow(at: indexPath) as? LoadTableViewCell {
                    cell.start()
                }
                let model = controller.modelInstance(inSection: indexPath.section)
                expand(model: model, incrementPage: true, section: indexPath.section)
            }
        }
    }

    private func expand(model: SectionViewModel?, incrementPage: Bool = false, section: Int) {
        // Reusing the same model, but focus in this section
        controller.expand(model: model, section: section,
                          incrementPage: incrementPage,
                          startClosure: {
            RestApi.instance.context?.performAndWait {
                SwiftSpinner.show(Quote.randomQuote())
            }
        }, finishClosure: { (error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(error: error)
                }
                Analytics.logError(error: error)
            }
            SwiftSpinner.hide()
            
            self.reloadData(section)
        })
    }

    /// Handler of the pull to refresh, it clears the info container, reload the view and made another request using RestApi
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        DispatchQueue.main.async {
            Analytics.logFunction(function: "refresh",
                                  parameters: ["method": "control" as AnyObject,
                                               "controller": self.titleForController() as AnyObject])

            self.refresh(isClean: true, refreshControl: refreshControl)
        }
    }

    @IBAction func trashAction(_ sender: Any) {
        let alert = UIAlertController(title: "Bookmark Reset", message: "Do you want to clean your bookmarks?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        let clean = UIAlertAction.init(title: "Clean", style: .destructive) { _ in
            DispatchQueue.main.async {
                SwiftSpinner.show(Quote.randomQuote())
            }

            Audio.clean()
            CloudKitManager.instance.clean(finishClosure: { (error) in
                if error != nil {
                    self.showAlert(title: "Error", message: "Trying to clean", error: error)
                    DispatchQueue.main.async {
                        SwiftSpinner.hide()
                    }
                } else {
                    self.refresh(isClean: true)
                }
            })
        }
        alert.addAction(clean)
        self.present(alert, animated: true, completion: nil)
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
        let search = UIAlertAction.init(title: "Search", style: .default) { _ in
            guard let textToSearch = alert.textFields?[0],
                let text = textToSearch.text,
                !text.isEmpty else {
                return
            }
            if self.controller is SearchController {
                (self.controller as? SearchController)?.textToSearch = text
                self.refresh(isClean: true)
            } else {
                self.performSegue(withIdentifier: Commons.Segue.search, sender: text)
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

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderTableView.reuseIdentifier) as? HeaderTableView
        headerView?.model = controller.modelInstance(inSection: section)
        headerView?.actionExpandBlock = { model, isHighlighted in
            DispatchQueue.main.async {
                self.expand(model: model, section: section)
            }
        }
        headerView?.infoBlock = { model in
            self.info(model: model)
        }
        return headerView
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let object = controller.model(forSection: indexPath.section, row: indexPath.row)
        if object is AudioViewModel {
            return indexPath
        }
        if let section = object as? SectionViewModel {
            if section.selectionStyle == .none {
                return nil
            }
        }
        return indexPath
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        var actions = [UITableViewRowAction]()

        let object = controller.model(forSection: indexPath.section, row: indexPath.row)
        var isBookmark: Bool? = false
        let stream = StreamPlaybackManager.instance
        if let audio = object as? AudioViewModel {
            let isPlaying = stream.isPlaying(url: audio.urlString())
            let playAction = UITableViewRowAction(style: .normal, title: isPlaying ? "Pause" : "Play") { (_, indexPath) in
                DispatchQueue.main.async {
                    self.play(indexPath: indexPath)
                }
            }
            playAction.backgroundColor = .cayenne
            actions.append(playAction)

            isBookmark = audio.isBookmark
        }

        if let section = object as? SectionViewModel {
            isBookmark = section.isBookmark
        }
        if let isBookmark = isBookmark {
            let actionTitle = controller is BookmarkController || isBookmark ? "Delete" : "Add"
            let bookmarkAction = UITableViewRowAction(style: .destructive, title: actionTitle) { (_, indexPath) in
                self.removeBookmark(indexPath: indexPath)
            }
            bookmarkAction.backgroundColor = controller is BookmarkController || isBookmark ? .lavender : .blueberry
            actions.append(bookmarkAction)
        }

        let shareAction = UITableViewRowAction(style: .normal, title: "Share") { (_, indexPath) in
            self.share(indexPath: indexPath, controller: self.controller, tableView: self.tableView)
        }
        shareAction.backgroundColor = .orchid
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
        if let section = object as? SectionViewModel {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SectionTableViewCell.reuseIdentifier, for: indexPath) as? SectionTableViewCell else { fatalError() }
            cell.model = section
            cell.actionBookmarkBlock = { catalog, isBookmarking in
                self.controller.changeBookmark(indexPath: indexPath)
            }
            cell.infoBlock = { catalog in
                self.info(model: catalog)
            }
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LoadTableViewCell.reuseIdentifier, for: indexPath) as? LoadTableViewCell else { fatalError() }
        if controller is BookmarkController {
            cell.titleView?.text = "You should tap on the Apple button to get some."
        } else if controller is SearchController {
            if (controller as? SearchController)?.numberOfRows(inSection: indexPath.section) == 0 {
                cell.tryAgain()
            } else {
                cell.clear()
            }
        } else {
            cell.clear()
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.play(indexPath: indexPath)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Commons.Segue.catalog {
            segue.destination.tabBarItem.title = AudioViewModel.ControllerName.radioTime.rawValue
            (segue.destination as? AudioViewController)?.controller = RadioTimeController(withCatalogViewModel: (sender as? SectionViewModel))
        } else if segue.identifier == Commons.Segue.archiveorg {
            segue.destination.tabBarItem.title = AudioViewModel.ControllerName.archiveMainModelOrg.rawValue
            (segue.destination as? AudioViewController)?.controller = ArchiveOrgMainModelController(withCatalogViewModel: (sender as? SectionViewModel))
        } else if segue.identifier == Commons.Segue.search {
            segue.destination.tabBarItem.title = AudioViewModel.ControllerName.search.rawValue
            (segue.destination as? AudioViewController)?.controller = SearchController(withText: (sender as? String))
        }
        SwiftSpinner.hide()
    }

    private func removeBookmark(indexPath: IndexPath) {
        if controller is BookmarkController {
            _ = (controller as? BookmarkController)?.remove(indexPath: indexPath) { error in
                if let error = error {
                    self.showAlert(title: error.title(), message: error.message(), error: error)
                } else {
                    self.refresh()
                }
            }
        } else {
            controller.changeBookmark(indexPath: indexPath)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

/**
 Extend `AudioViewController` to conform to the `AudioTableViewCellDelegate` protocol.
 */
extension AudioViewController: AudioTableViewCellDelegate {

    func audioTableViewCell(_ cell: AudioTableViewCell, infoDidTap newState: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        info(indexPath: indexPath)
    }

    func audioTableViewCell(_ cell: AudioTableViewCell, bookmarkDidChange newState: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        removeBookmark(indexPath: indexPath)
    }

    func audioTableViewCell(_ cell: AudioTableViewCell, downloadStateDidChange newState: Stream.DownloadState) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

}

extension AudioViewController: AssetPlaybackDelegate {
    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerReadyToPlay player: AVPlayer, isPlaying: Bool) {
         if let currentPlayIndexPath = currentPlayIndexPath {
            reloadData(currentPlayIndexPath.section, currentPlayIndexPath.row)
        }
    }
    
    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerCurrentItemDidChange player: AVPlayer) {
        if let currentPlayIndexPath = currentPlayIndexPath {
            reloadData(currentPlayIndexPath.section, currentPlayIndexPath.row)
        }
    }
    
    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerCurrentItemDidDetectDuration player: AVPlayer, duration: TimeInterval) {
        if let currentPlayIndexPath = currentPlayIndexPath {
            reloadData(currentPlayIndexPath.section, currentPlayIndexPath.row)
        }
    }
    
    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerError error: JFError, audio: Audio?) {
        if let currentPlayIndexPath = currentPlayIndexPath {
            reloadData(currentPlayIndexPath.section, currentPlayIndexPath.row)
        }
        showAlert(title: "Player Error", message: "When trying to play \(audio?.titleText ?? "")", error: error)
    }
    
}
