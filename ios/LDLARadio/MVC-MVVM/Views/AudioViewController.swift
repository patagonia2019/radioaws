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

class AudioViewController: UIViewController {
    // MARK: Properties

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var toolbar: Toolbar!

    var currentPlayIndexPath: IndexPath?
    var lastTitleName: String = AudioViewModel.ControllerName.LosLocos.rawValue
    fileprivate var timerPlayed: Timer?
    var radioController = RadioController()
    var radioTimeController = RadioTimeController()
    var rnaController = RNAController()
    var bookmarkController = BookmarkController()
    var desconciertoController = ElDesconciertoController()
    var searchController = SearchController()
    var archiveOrgController = ArchiveOrgController()
    var archiveOrgMainModelController = ArchiveDocController()
        
    // TODO: replace with generic func getControl<T:Controllable>() -> T {
    var controller: BaseController? {
        get {
            let name = controllerName()
            switch name {
            case .LosLocos: return radioController
            case .RT: return radioTimeController
            case .RNA: return rnaController
            case .MyPick: return bookmarkController
            case .Desconcierto: return desconciertoController
            case .ArchiveOrg: return archiveOrgController
            case .ArchiveOrgMain: return archiveOrgMainModelController
            case .Search: return searchController
            default: fatalError()
            }
        }
        set {
            let name = controllerName()
            switch name {
            case .LosLocos:
                if let newValue = newValue as? RadioController {
                    radioController = newValue
                }
            case .RT:
                if let newValue = newValue as? RadioTimeController {
                    radioTimeController = newValue
                }
            case .RNA:
                if let newValue = newValue as? RNAController {
                    rnaController = newValue
                }
            case .MyPick:
                if let newValue = newValue as? BookmarkController {
                    bookmarkController = newValue
                }
            case .Desconcierto:
                if let newValue = newValue as? ElDesconciertoController {
                    desconciertoController = newValue
                }
            case .ArchiveOrg:
                if let newValue = newValue as? ArchiveOrgController {
                    archiveOrgController = newValue
                }
            case .ArchiveOrgMain:
                if let newValue = newValue as? ArchiveDocController {
                    archiveOrgMainModelController = newValue
                }
            case .Search:
                if let newValue = newValue as? SearchController {
                    searchController = newValue
                }
            default: fatalError()
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
        stream.delegate = toolbar
        SwiftSpinner.useContainerView(view)
        
        HeaderTableView.setup(tableView: tableView)
        tableView.remembersLastFocusedIndexPath = true
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)

        navigationController?.setToolbarHidden(true, animated: false)
        toolbar.isHidden = true
        
        if let controller = controller {
            if controller.useRefresh {
                addRefreshControl()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        var buttons = [UIBarButtonItem]()
        buttons.append(searchButton)
        if controller is BookmarkController {
            buttons.append(trashButton)
        }
        navigationItem.rightBarButtonItems = buttons
        updateNavBar()
        refresh(isClean: controller is SearchController)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let timerPlayed = timerPlayed {
            timerPlayed.invalidate()
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadData()
    }

    private func controllerName() -> AudioViewModel.ControllerName? {
        if !Thread.isMainThread {
            Log.error("NOT Main Thread %@", lastTitleName)
            fatalError()
        }

        lastTitleName = self.tabBarItem.title ?? self.navigationController?.tabBarItem.title ?? self.tabBarController?.selectedViewController?.tabBarItem.title ?? lastTitleName
        return AudioViewModel.ControllerName(rawValue: lastTitleName)
    }

    /// Refresh control to allow pull to refresh
    private func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.accessibilityHint = "refresh"
        refreshControl.accessibilityLabel = "refresh"
        refreshControl.addTarget(self, action: #selector(AudioViewController.handleRefresh(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.red

        tableView.addSubview(refreshControl)

    }

    lazy var searchButton: UIBarButtonItem = {
        let search = UIButton(type: .custom)
        search.addTarget(self, action: #selector(AudioViewController.searchAction(_:)), for: .touchUpInside)
        let size = Commons.Size.toolbarButtonFontSize
        search.heightAnchor.constraint(equalToConstant: size).isActive = true
        search.widthAnchor.constraint(equalToConstant: size).isActive = true
        search.frame.size = CGSize(width: size, height: size)
        search.setTitleColor(.blue, for: .normal)
        search.setTitleColor(.steel, for: .highlighted)
        search.titleLabel?.font = UIFont(name: Commons.Font.awesome, size: 30)
        search.setTitle("\(Commons.Symbol.showAwesome(icon: .search))", for: .normal)
        return UIBarButtonItem(customView: search)
    }()

    lazy var trashButton: UIBarButtonItem = {
        let trash = UIButton(type: .custom)
        trash.addTarget(self, action: #selector(AudioViewController.trashAction(_:)), for: .touchUpInside)
        let size = Commons.Size.toolbarButtonFontSize
        trash.heightAnchor.constraint(equalToConstant: size).isActive = true
        trash.widthAnchor.constraint(equalToConstant: size).isActive = true
        trash.frame.size = CGSize(width: size, height: size)
        trash.setTitleColor(.maraschino, for: .normal)
        trash.setTitleColor(.steel, for: .highlighted)
        trash.titleLabel?.font = UIFont(name: Commons.Font.awesome, size: 30)
        trash.setTitle("\(Commons.Symbol.showAwesome(icon: .trash))", for: .normal)
        return UIBarButtonItem(customView: trash)
    }()

    func refresh(isClean: Bool = false, refreshControl: UIRefreshControl? = nil) {

        guard let controller = controller else {
            return
        }
        controller.refresh(isClean: isClean, prompt: "", startClosure: {
            DispatchQueue.main.async {
                SwiftSpinner.show(Quote.randomQuote())
            }
        }, finishClosure: { (error) in
            if let error = error {
                Analytics.logError(error: error)
                DispatchQueue.main.async {
                    self.showAlert(error: error)
                    // TODO: show something in the table that there are no results
//                    if controller.numberOfSections() == 0 {
//                        self.navigationController?.dismiss(animated: true, completion: nil)
//                        return
//                    }
                }
            }
            refreshControl?.endRefreshing()
            SwiftSpinner.hide()
            self.reloadData()
        })
    }

    func updateNavBar() {
        guard let controller = controller else {
            return
        }

        navigationItem.prompt = " "
        for view in navigationController?.navigationBar.subviews ?? [] where NSStringFromClass(view.classForCoder) == "_UINavigationBarModernPromptView" {
            if let prompt = view.subviews.first as? UILabel {
                prompt.text = controller.prompt()
                prompt.textColor = .midnight
                let font = UIFont(name: Commons.Font.bold, size: 12)
                prompt.font = font
            }
        }
        navigationItem.titleView = titleView
    }

    var titleView: UIView {
        let label = UILabel()
        label.text = controller?.title()
        label.textColor = .midnight
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 3
        return label
    }
    
    private func reloadData(_ section: Int? = nil, _ row: Int? = nil) {
        guard let controller = controller else {
            return
        }
        
        _ = tableView.numberOfSections

        if !Thread.isMainThread {
            Log.fault("fatal error is not Main Thread")
            fatalError()
        }
        tableView.refreshControl?.attributedTitle = controller.title().bigRed()
        updateNavBar()
        if let section = section, let row = row {
            _ = tableView.numberOfRows(inSection: section)
            tableView.beginUpdates()
            tableView.reloadRows(at: [IndexPath(row: row, section: section)], with: .none)
            tableView.endUpdates()
        } else if let section = section {
            _ = tableView.numberOfRows(inSection: section)
            tableView.beginUpdates()
            tableView.reloadSections(IndexSet(integer: section), with: .none)
            tableView.endUpdates()
        } else {
            tableView.reloadData()
        }
        
        reloadTimer()
    }

    private func reloadTimer() {

        let stream = StreamPlaybackManager.instance

        if let timerPlayed = timerPlayed {
            timerPlayed.invalidate()
        }
        if stream.isAboutToPlay() {
            timerPlayed = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(reloadToolbar), userInfo: nil, repeats: true)
        } else {
            toolbar.isHidden = true
        }
    }

    @objc private func reloadToolbar() {

        let stream = StreamPlaybackManager.instance
        let show = !stream.isPlaying()
        toolbar.isHidden = show
        if !show {
            return
        }
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseInOut, animations: {
            if var rect = self.tabBarController?.tabBar.frame {
                rect.origin.y -= rect.size.height
                self.toolbar.frame = rect
            }
        }, completion: { _ in
            self.toolbar.setNeedsLayout()
            self.toolbar.setNeedsDisplay()
        })
    }

    private func info(model: SectionViewModel?) {
        showAlert(title: model?.title.text, message: model?.text, error: nil)
    }

    private func info(indexPath: IndexPath) {
        let object = controller?.model(forSection: indexPath.section, row: indexPath.row)
        if let audio = object as? AudioViewModel {
            showAlert(title: audio.title.text, message: audio.info, error: nil)
        } else if let section = object as? SectionViewModel {
            info(model: section)
        }
    }

    private func play(indexPath: IndexPath, isReload: Bool = true) {
        guard let controller = controller else { return }
        let object = controller.model(forSection: indexPath.section, row: indexPath.row)
        if object is AudioViewModel {
            DispatchQueue.main.async {
                if (object as? AudioViewModel) != nil {
                    self.currentPlayIndexPath = indexPath
                    self.reloadData(indexPath.section, indexPath.row)
                }
                DispatchQueue.global(qos: .background).async {
                    controller.play(forSection: indexPath.section, row: indexPath.row)
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
                if section.section == AudioViewModel.ControllerName.RT.rawValue {
                    performSegue(withIdentifier: Commons.Segue.catalog, sender: section)
                } else if section.section == AudioViewModel.ControllerName.ArchiveOrg.rawValue {
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
        guard let controller = controller else { return }
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
                                               "controller": self.controllerName()?.rawValue as AnyObject])

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Commons.Segue.catalog {
            segue.destination.tabBarItem.title = AudioViewModel.ControllerName.RT.rawValue
            (segue.destination as? AudioViewController)?.controller = RadioTimeController(withCatalogViewModel: (sender as? SectionViewModel))
        } else if segue.identifier == Commons.Segue.archiveorg {
            segue.destination.tabBarItem.title = AudioViewModel.ControllerName.ArchiveOrgMain.rawValue
            (segue.destination as? AudioViewController)?.controller = ArchiveDocController(withCatalogViewModel: (sender as? SectionViewModel))
        } else if segue.identifier == Commons.Segue.search {
            segue.destination.tabBarItem.title = AudioViewModel.ControllerName.Search.rawValue
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
            controller?.changeBookmark(indexPath: indexPath)
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
        DispatchQueue.main.async {
            if let currentPlayIndexPath = self.currentPlayIndexPath {
                self.reloadData(currentPlayIndexPath.section, currentPlayIndexPath.row)
            }
        }
    }
    
    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerCurrentItemDidChange player: AVPlayer) {
        DispatchQueue.main.async {
            if let currentPlayIndexPath = self.currentPlayIndexPath {
                self.reloadData(currentPlayIndexPath.section, currentPlayIndexPath.row)
            }
        }
    }
    
    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerCurrentItemDidDetectDuration player: AVPlayer, duration: TimeInterval) {
        DispatchQueue.main.async {
            if let currentPlayIndexPath = self.currentPlayIndexPath {
                self.reloadData(currentPlayIndexPath.section, currentPlayIndexPath.row)
            }
        }
    }
    
    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerError error: JFError, audio: Audio?) {
        DispatchQueue.main.async {
            if let currentPlayIndexPath = self.currentPlayIndexPath {
                self.reloadData(currentPlayIndexPath.section, currentPlayIndexPath.row)
            }
            self.showAlert(title: "Player Error", message: "When trying to play \(audio?.titleText ?? "")", error: error)
        }
    }
    
}

extension AudioViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let controller = controller else { return 0 }
        return controller.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let controller = controller else { return 0 }
        return controller.numberOfRows(inSection: section)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let controller = controller else { return nil }
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderTableView.reuseIdentifier) as? HeaderTableView
        
        if let model = controller.modelInstance(inSection: section) {
            headerView?.actionExpandBlock = { model, isHighlighted in
                DispatchQueue.main.async {
                    self.expand(model: model, section: section)
                }
            }
            headerView?.infoBlock = { model in
                self.info(model: model)
            }
            headerView?.model = model
            if controller.numberOfSections() == 1 {
                headerView?.model?.isCollapsed = nil
            }
        }
        return headerView
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let controller = controller else { return nil }

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

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let controller = controller else { return nil }

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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let object = controller?.model(forSection: indexPath.section, row: indexPath.row)
        if let audio = object as? AudioViewModel {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AudioTableViewCell.reuseIdentifier, for: indexPath) as? AudioTableViewCell else { fatalError() }
            cell.delegate = self
            audio.showSeparator = !(indexPath.row + 1 == controller?.numberOfRows(inSection: indexPath.section))
            cell.model = audio
            return cell
        }
        if let section = object as? SectionViewModel {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SectionTableViewCell.reuseIdentifier, for: indexPath) as? SectionTableViewCell else { fatalError() }
            cell.model = section
            cell.actionBookmarkBlock = { catalog, isBookmarking in
                self.controller?.changeBookmark(indexPath: indexPath)
            }
            cell.infoBlock = { catalog in
                self.info(model: catalog)
            }
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LoadTableViewCell.reuseIdentifier, for: indexPath) as? LoadTableViewCell else { fatalError() }
        if controller is BookmarkController {
            cell.titleView?.text = "Missing something here."
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.play(indexPath: indexPath)
        }
    }
}
