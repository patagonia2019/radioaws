//
//  ArchiveOrgMainModelController.swift
//  LDLARadio
//
//  Created by fox on 11/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import JFCore
import AlamofireCoreData

class ArchiveOrgMainModelController: BaseController {

    fileprivate var mainModel: SectionViewModel?

    override init() { }

    init(withCatalogViewModel catalogViewModel: SectionViewModel?) {
        mainModel = catalogViewModel
    }

    override func numberOfSections() -> Int {
        var n = 0
        if let model = mainModel {
            n = model.sections.count
            n += (model.audios.isEmpty ? 0 : 1)
        }
        return n
    }

    override func title() -> String {
        return mainModel?.title.text ??
            AudioViewModel.ControllerName.ArchiveOrg.rawValue
    }

    override func numberOfRows(inSection section: Int) -> Int {
        var rows: Int = 0
        if let model = mainModel {
            if section < model.sections.count {
                let subModel = model.sections[section]
                if subModel.isCollapsed == true {
                    return 0
                }
                rows = subModel.sections.count + subModel.audios.count
            } else {
                rows = model.audios.count
            }
        }
        return rows > 0 ? rows : 2
    }

    override func modelInstance(inSection section: Int) -> SectionViewModel? {
        if let model = mainModel,
            section < model.sections.count {
            return model.sections[section]
        }
        return mainModel
    }

    override func model(forSection section: Int, row: Int) -> Any? {
        if let model = mainModel {
            if section < model.sections.count {
                let subModel = model.sections[section]
                if row < (subModel.sections.count + subModel.audios.count) {
                    if row < subModel.sections.count {
                        return subModel.sections[row]
                    }
                    let audioRow = row - subModel.sections.count
                    if audioRow < subModel.audios.count {
                        return subModel.audios[audioRow]
                    }
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
        if let doc = ArchiveDoc.search(byIdentifier: mainModel?.id) {
            mainModel = SectionViewModel(archiveDoc: doc)
        }
        lastUpdated = ArchiveCollection.lastUpdated()
    }

    override func privateRefresh(isClean: Bool = false,
                                 prompt: String = "Archive.org",
                                 finishClosure: ((_ error: JFError?) -> Void)? = nil) {

        let doc = ArchiveDoc.search(byIdentifier: mainModel?.id)

        if isClean == false {
            if doc?.detail?.archiveFiles?.count ?? 0 > 0 {

                mainModel = SectionViewModel(archiveDoc: doc)

                lastUpdated = ArchiveCollection.lastUpdated()
                finishClosure?(nil)
                return
            }
        }

        RestApi.instance.context?.performAndWait {

            RestApi.instance.requestARCH(usingUrl: doc?.urlString(), type: ArchiveDetail.self) { error, detail in

                let archiveDoc = ArchiveDoc.search(byIdentifier: doc?.identifier)
                detail?.extractFiles()
                archiveDoc?.detail = detail

                let meta = ArchiveMeta.search(byCollectionIdentifier: self.mainModel?.parentId)
                archiveDoc?.response?.meta = meta
                CoreDataManager.instance.save()
                self.updateModels()

                DispatchQueue.main.async {
                    finishClosure?(error)
                }
            }
        }
    }

    internal override func expanding(model: SectionViewModel?, section: Int, incrementPage: Bool, startClosure: (() -> Void)? = nil, finishClosure: ((_ error: JFError?) -> Void)? = nil) {

        if let isCollapsed = model?.isCollapsed {
            model?.isCollapsed = !isCollapsed
        }

        finishClosure?(nil)
    }
}
