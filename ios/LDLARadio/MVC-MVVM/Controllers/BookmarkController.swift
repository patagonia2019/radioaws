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
        var count: Int = 0
        if section < models.count {
            let model = models[section]
            if model.isExpanded == false {
                return 0
            }
            count = model.sections.count + model.audios.count
        }
        return count > 0 ? count : 1
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

    override func heightForRow(at section: Int, row: Int) -> CGFloat {
        let subModel = model(forSection: section, row: row)
        if let audioModel = subModel as? AudioViewModel {
            return CGFloat(audioModel.height())
        }
        return CGFloat(CatalogViewModel.cellheight)
    }

    override func privateRefresh(isClean: Bool = false,
                                 prompt: String,
                                 finishClosure: ((_ error: JFError?) -> Void)? = nil) {

        let closure = {

            self.models = [CatalogViewModel]()

            RestApi.instance.context?.performAndWait {
                let all = Bookmark.all()

                if let suggestions = all?.filter({ (bookmark) -> Bool in
                    return bookmark.section == AudioViewModel.ControllerName.suggestion.rawValue
                }), suggestions.count > 0 {
                    let audios = suggestions.map({ AudioViewModel(bookmark: $0) })
                    if audios.count > 0 {

                        let model = CatalogViewModel()
                        model.isExpanded = false
                        model.title.text = AudioViewModel.ControllerName.suggestion.rawValue
                        model.audios = audios
                        self.models.append(model)

                    }
                }

                if let rnas = all?.filter({ (bookmark) -> Bool in
                    return bookmark.section == AudioViewModel.ControllerName.rna.rawValue
                }), rnas.count > 0 {
                    let audios = rnas.map({ AudioViewModel(bookmark: $0) })
                    if audios.count > 0 {

                        let model = CatalogViewModel()
                        model.isExpanded = false
                        model.title.text = AudioViewModel.ControllerName.rna.rawValue
                        model.audios = audios
                        self.models.append(model)

                    }
                }

                if let rts = all?.filter({ (bookmark) -> Bool in
                    return bookmark.section == AudioViewModel.ControllerName.radioTime.rawValue
                }), rts.count > 0 {
                    let audios = rts.map({ AudioViewModel(bookmark: $0) })
                    if audios.count > 0 {
                        let model = CatalogViewModel()
                        model.isExpanded = false
                        model.title.text = AudioViewModel.ControllerName.radioTime.rawValue
                        model.audios = audios
                        self.models.append(model)
                    }
                }

                if let eds = all?.filter({ (bookmark) -> Bool in
                    return bookmark.section == AudioViewModel.ControllerName.desconcierto.rawValue
                }), eds.count > 0 {
                    let audios = eds.map({ AudioViewModel(bookmark: $0) })
                    if audios.count > 0 {
                        let model = CatalogViewModel()
                        model.isExpanded = false
                        model.title.text = AudioViewModel.ControllerName.desconcierto.rawValue
                        model.audios = audios
                        self.models.append(model)
                    }
                }

                if let files = all?.filter({ (bookmark) -> Bool in
                    return bookmark.section == AudioViewModel.ControllerName.archiveOrg.rawValue || bookmark.section == AudioViewModel.ControllerName.archiveMainModelOrg.rawValue
                }), files.count > 0 {
                    let audios = files.map({ AudioViewModel(bookmark: $0) })
                    if audios.count > 0 {
                        let model = CatalogViewModel()
                        model.isExpanded = false
                        model.title.text = AudioViewModel.ControllerName.archiveOrg.rawValue
                        model.audios = audios
                        self.models.append(model)
                    }
                }
                finishClosure?(nil)
            }
        }

        var forceUpdate = false

        if isClean || BaseController.isBookmarkChanged {
            forceUpdate = true
            BaseController.isBookmarkChanged = false
        } else {
            if self.models.count > 0 {
                finishClosure?(nil)
                return
            }

            if Bookmark.all()?.count ?? 0 == 0 {
                forceUpdate = true
            }
        }

        if forceUpdate && cloudKit.loggedIn {

            RestApi.instance.context?.performAndWait {
                Bookmark.clean()
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

        model?.isExpanded = !(model?.isExpanded ?? false)

        finishClosure?(nil)
    }

}
