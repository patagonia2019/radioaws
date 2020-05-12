//
//  BookmarkController.swift
//  LDLARadio
//
//  Created by fox on 24/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import JFCore

class BookmarkController: BaseController {

    /// Notification for when bookmark has changed.
    static let didRefreshNotification = NSNotification.Name(rawValue: "BookmarkController.didRefreshNotification")

    let cloudKit: CloudKitManager = CloudKitManager.instance

    private var models = [CatalogViewModel]()

    override var useRefresh: Bool {
        return cloudKit.loggedIn
    }

    override init() {
        super.init()
    }

    override func prompt() -> String {
        return "Bookmarks"
    }

    override func numberOfSections() -> Int {
        return models.count
    }

    override func numberOfRows(inSection section: Int) -> Int {
        var rows: Int = 0
        if section < models.count {
            let model = models[section]
            if model.isCollapsed == true {
                return 0
            }
            rows = model.sections.count + model.audios.count
        }
        return rows > 0 ? rows : 1
    }

    override func modelInstance(inSection section: Int) -> CatalogViewModel? {
        if section < models.count {
            let model = models[section]
            return model
        }
        return models.first
    }

    override func model(forSection section: Int, row: Int) -> Any? {
        if section < models.count {
            let model = models[section]
            if row < (model.sections.count + model.audios.count) {
                if row < model.sections.count {
                    return model.sections[row]
                }
                let audioRow = row - model.sections.count
                if audioRow < model.audios.count {
                    return model.audios[audioRow]
                }
            } else {
                if row < model.audios.count {
                    return model.audios[row]
                }
            }
        }
        return nil
    }

    override func privateRefresh(isClean: Bool = false,
                                 prompt: String,
                                 finishClosure: ((_ error: JFError?) -> Void)? = nil) {

        let closure = {

            self.models = [CatalogViewModel]()

            RestApi.instance.context?.performAndWait {
                let all = Audio.all()

                if let suggestions = all?.filter({ (bookmark) -> Bool in
                    bookmark.section == AudioViewModel.ControllerName.suggestion.rawValue}), !suggestions.isEmpty {
                    let audios = suggestions.map({ AudioViewModel(audio: $0) })
                    if !audios.isEmpty {

                        let model = CatalogViewModel()
                        model.isCollapsed = true
                        model.title.text = AudioViewModel.ControllerName.suggestion.rawValue
                        model.audios = audios
                        self.models.append(model)

                    }
                }

                if let rnas = all?.filter({ (bookmark) -> Bool in
                    bookmark.section == AudioViewModel.ControllerName.rna.rawValue
                }), !rnas.isEmpty {
                    let audios = rnas.map({ AudioViewModel(audio: $0) })
                    if !audios.isEmpty {

                        let model = CatalogViewModel()
                        model.isCollapsed = true
                        model.title.text = AudioViewModel.ControllerName.rna.rawValue
                        model.audios = audios
                        self.models.append(model)

                    }
                }

                if let rts = all?.filter({ (bookmark) -> Bool in
                    bookmark.section == AudioViewModel.ControllerName.radioTime.rawValue
                }), !rts.isEmpty {
                    let audios = rts.map({ AudioViewModel(audio: $0) })
                    if !audios.isEmpty {
                        let model = CatalogViewModel()
                        model.isCollapsed = true
                        model.title.text = AudioViewModel.ControllerName.radioTime.rawValue
                        model.audios = audios
                        self.models.append(model)
                    }
                }

                if let eds = all?.filter({ (bookmark) -> Bool in
                    bookmark.section == AudioViewModel.ControllerName.desconcierto.rawValue
                }), !eds.isEmpty {
                    let audios = eds.map({ AudioViewModel(audio: $0) })
                    if !audios.isEmpty {
                        let model = CatalogViewModel()
                        model.isCollapsed = true
                        model.title.text = AudioViewModel.ControllerName.desconcierto.rawValue
                        model.audios = audios
                        self.models.append(model)
                    }
                }

                if let files = all?.filter({ (bookmark) -> Bool in
                    bookmark.section == AudioViewModel.ControllerName.archiveOrg.rawValue || bookmark.section == AudioViewModel.ControllerName.archiveMainModelOrg.rawValue
                }), !files.isEmpty {
                    let audios = files.map({ AudioViewModel(audio: $0) })
                    if !audios.isEmpty {
                        let model = CatalogViewModel()
                        model.isCollapsed = true
                        model.title.text = AudioViewModel.ControllerName.archiveOrg.rawValue
                        model.audios = audios
                        self.models.append(model)
                    }
                }
                finishClosure?(nil)
            }
        }

        var forceUpdate = false

        if isClean {
            forceUpdate = true
        } else {
            if BaseController.isBookmarkChanged {
                closure()
            }

            if !models.isEmpty {
                finishClosure?(nil)
                return
            }

            if Audio.all()?.isEmpty ?? false {
                forceUpdate = true
            }
        }

        if forceUpdate && cloudKit.loggedIn {

            RestApi.instance.context?.performAndWait {
                cloudKit.refresh { (error) in
                    if error != nil {
                        CoreDataManager.instance.rollback()
                    } else {
                        CoreDataManager.instance.save()
                    }
                    closure()
                }
            }
        } else {
            closure()
        }
    }

    internal override func expanding(model: CatalogViewModel?, section: Int, incrementPage: Bool, startClosure: (() -> Void)? = nil, finishClosure: ((_ error: JFError?) -> Void)? = nil) {

        model?.isCollapsed = !(model?.isCollapsed ?? false)

        finishClosure?(nil)
    }

    func remove(indexPath: IndexPath, finishClosure: ((_ error: JFError?) -> Void)? = nil) -> Bool {
        let object = model(forSection: indexPath.section, row: indexPath.row)

        if let model = object as? AudioViewModel,
            let audio = Audio.search(byUrl: model.urlString()) {
            if CloudKitManager.instance.loggedIn {
                CloudKitManager.instance.remove(audio: audio) { (error) in
                    if let error = error {
                        model.error = error
                    } else {
                        audio.remove()
                        self.models.removeAll { (ct) -> Bool in
                            ct.urlString() == model.urlString()
                        }
                    }
                    finishClosure?(error)
                }
            } else {
                audio.remove()
                let catalog = models[indexPath.section]
                var audios = catalog.audios
                audios.removeAll { (audiovm) -> Bool in
                    audiovm.urlString() == model.urlString()
                }
                catalog.audios = audios
                finishClosure?(nil)
            }
            return true
        }
        return false
    }

}
