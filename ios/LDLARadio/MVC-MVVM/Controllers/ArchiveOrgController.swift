//
//  ArchiveOrgController.swift
//  LDLARadio
//
//  Created by fox on 11/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import JFCore
import AlamofireCoreData

class ArchiveOrgController: BaseController {

    fileprivate var models = [SectionViewModel]()

    override init() { }

    override func numberOfSections() -> Int {
        return models.count
    }

    override func title() -> String {
        return AudioViewModel.ControllerName.ArchiveOrg.rawValue
    }

    override func numberOfRows(inSection section: Int) -> Int {
        var rows: Int = 0
        var additionalRowToReload: Int = 0
        if section < models.count {
            let model = models[section]
            if model.isCollapsed == true {
                return 0
            }

            if let archiveCollection = ArchiveCollection.search(byIdentifier: model.id) {
                additionalRowToReload = archiveCollection.nextPage == nil ? 0 : 1
            }

            rows = model.sections.count + model.audios.count
        }
        return rows > 0 ? (rows + additionalRowToReload) : additionalRowToReload
    }

    override func modelInstance(inSection section: Int) -> SectionViewModel? {
        if section < models.count {
            let model = models[section]
            return model
        }
        return models.first
    }
    
    override func play(forSection section: Int, row: Int) {
        super.play(forSection: section, row: row)
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

    private func updateModels() {
        if let collections = ArchiveCollection.all() {
            func isCollapsed(ac: ArchiveCollection?) -> Bool {
                return models.filter { (catalog) -> Bool in
                    (catalog.isCollapsed ?? true) && ac?.identifier == catalog.id
                }.isEmpty == false
            }
            models = collections.map({ SectionViewModel(archiveCollection: $0, isAlreadyCollapsed: isCollapsed(ac: $0)) })
        }
        lastUpdated = ArchiveCollection.lastUpdated()
    }

    override func privateRefresh(isClean: Bool = false,
                                 prompt: String = "Archive.org",
                                 finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        if isClean == false {
            updateModels()
            if !models.isEmpty {
                finishClosure?(nil)
                return
            }
        }

        RestApi.instance.context?.performAndWait {

            ArchiveCollection.clean()
            ArchiveMeta.clean()
            ArchiveDoc.clean() // ArchiveDetail.clean()
            ArchiveFile.clean()
            ArchiveResponse.clean()
            ArchiveResponseHeader.clean()

            RestApi.instance.requestLDLA(usingQuery: "/archivecatalogs.json", type: Many<ArchiveCollection>.self) { error, _ in

                if error != nil {
                    CoreDataManager.instance.rollback()
                } else {
                    CoreDataManager.instance.save()
                }
                self.updateModels()

                DispatchQueue.main.async {
                    finishClosure?(error)
                }
            }
        }

    }

    func changeCatalogBookmark(section: Int) {
        if section < models.count {
            let model = models[section]
            Audio.changeCatalogBookmark(model: model)
        }
    }

    internal override func expanding(model: SectionViewModel?, section: Int, incrementPage: Bool, startClosure: (() -> Void)? = nil, finishClosure: ((_ error: JFError?) -> Void)? = nil) {

        guard let archiveCollection = ArchiveCollection.search(byIdentifier: model?.id),
            let model = model else {
            finishClosure?(JFError(code: -1, desc: "Where is the catalog?", reason: "The collection is empty", suggestion: "Try to reload the whole catalog.", underError: nil))
            return
        }
        var page = archiveCollection.currentPage
        
        if (!model.audios.isEmpty || !model.sections.isEmpty) && incrementPage == false {
            archiveCollection.isCollapsed = !archiveCollection.isCollapsed
            
            model.reload(archiveCollection: archiveCollection, isAlreadyCollapsed: archiveCollection.isCollapsed)
            
            finishClosure?(nil)
            return
        }

        if incrementPage == true, let nextPage = archiveCollection.nextPage {
            page = nextPage
        }
        archiveCollection.isCollapsed = false
        
        guard let url = archiveCollection.searchCollectionUrlString(page: page) ?? model.urlString() else {
            model.reload(archiveCollection: archiveCollection, isAlreadyCollapsed: archiveCollection.isCollapsed)
            finishClosure?(nil)
            return
        }

        RestApi.instance.context?.performAndWait {

            RestApi.instance.requestARCH(usingUrl: url, type: ArchiveMeta.self) { error, meta in

                if error == nil {
                    meta?.collection = archiveCollection

                    meta?.collectionIdentifier = archiveCollection.identifier ?? model.parentId
                    meta?.identifier = model.id

                    CoreDataManager.instance.save()
                }

                model.reload(archiveCollection: archiveCollection, isAlreadyCollapsed: archiveCollection.isCollapsed)

                DispatchQueue.main.async {
                    finishClosure?(error)
                }
            }
        }
    }

    static func search(text: String = "",
                       pageNumber: Int = 1,
                       finishClosure: ((_ error: JFError?) -> Void)? = nil) {

        if text.isEmpty {
            finishClosure?(nil)
            return
        }

        guard let text2Search = text.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else {
            finishClosure?(nil)
            return
        }

        let urlString = ArchiveCollection.searchUrlString(withString: text2Search, page: pageNumber)
        RestApi.instance.requestARCH(usingUrl: urlString, type: ArchiveMeta.self) { error, _ in

            if error != nil {
                DispatchQueue.main.async {
                    finishClosure?(error)
                }
                return
            }
            CoreDataManager.instance.save()

            DispatchQueue.main.async {
                finishClosure?(error)
            }
        }
    }

}
