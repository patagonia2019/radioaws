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

    fileprivate var models = [CatalogViewModel]()

    override init() { }

    override func numberOfSections() -> Int {
        return models.count
    }

    override func prompt() -> String {
        return AudioViewModel.ControllerName.archiveOrg.rawValue
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
        return count > 0 ? (count + 1) : 1
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
        return CGFloat(CatalogViewModel.cellheight) * 1.2
    }

    private func updateModels() {
        if let collections = ArchiveCollection.all() {
            func isExpanded(ac: ArchiveCollection?) -> Bool {
                return models.filter { (catalog) -> Bool in
                    return (catalog.isExpanded ?? false) && ac?.identifier == catalog.id
                    }.count > 0
            }
            models = collections.map({ CatalogViewModel(archiveCollection: $0, isAlreadyExpanded: isExpanded(ac: $0)) })
        }
        lastUpdated = ArchiveCollection.lastUpdated()
    }

    override func privateRefresh(isClean: Bool = false,
                                 prompt: String = "Archive.org",
                                 finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        if isClean == false {
            updateModels()
            if models.count > 0 {
                finishClosure?(nil)
                return
            }
        }

        RestApi.instance.context?.performAndWait {

            ArchiveCollection.clean()
            ArchiveMeta.clean()
            ArchiveDoc.clean()
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

    internal override func expanding(model: CatalogViewModel?, section: Int, incrementPage: Bool, startClosure: (() -> Void)? = nil, finishClosure: ((_ error: JFError?) -> Void)? = nil) {

        let archiveCollection = ArchiveCollection.search(byIdentifier: model?.id)

        if incrementPage, let page = model?.page {
            model?.page = page + 1
            model?.isExpanded = true
            archiveCollection?.isExpanded = true
        }

        if incrementPage == false {
            if let isExpanded = model?.isExpanded {
                model?.isExpanded = !isExpanded
                archiveCollection?.isExpanded = !isExpanded
            }
            
            if model?.audios.count ?? 0 > 0 || model?.sections.count ?? 0 > 0 {
                finishClosure?(nil)
                return
            }
            
            if ArchiveMeta.search(byIdentifier: archiveCollection?.identifier) != nil {
                self.updateModels()
                finishClosure?(nil)
                return
            }
        }

        let url = archiveCollection?.searchCollectionUrlString(page: model?.page ?? 1) ?? model?.urlString()
        if url == nil {
            self.updateModels()
            finishClosure?(nil)
            return
        }

        RestApi.instance.context?.performAndWait {

            RestApi.instance.requestARCH(usingUrl: url, type: ArchiveMeta.self) { error, meta in

                if error == nil {
                    meta?.collection = ArchiveCollection.search(byIdentifier: archiveCollection?.identifier ?? model?.parentId)

                    meta?.collectionIdentifier = archiveCollection?.identifier ?? model?.parentId
                    meta?.identifier = model?.id

                    CoreDataManager.instance.save()
                }

                self.updateModels()

                DispatchQueue.main.async {
                    finishClosure?(error)
                }
            }
        }
    }

    static func search(text: String = "",
                       pageNumber: Int = 1,
                       finishClosure: ((_ error: JFError?) -> Void)? = nil) {

        if text.count == 0 {
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
