//
//  RadioTimeController.swift
//  LDLARadio
//
//  Created by fox on 13/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import JFCore

class RadioTimeController: BaseController {

    fileprivate var mainModel: SectionViewModel?

    override init() {
        super.init()
        mainModel = SectionViewModel(catalog: mainCatalogFromDb(sectionViewModel: nil))
    }

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
        return rows > 0 ? rows : 1
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

    override func title() -> String {
        return mainModel?.tree ?? mainModel?.title.text ?? "Browse"
    }

    override func privateRefresh(isClean: Bool = false,
                                 prompt: String = AudioViewModel.ControllerName.RT.rawValue,
                                 finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        
        guard let mainModel = mainModel,
            var mainCatalog = mainCatalogFromDb(sectionViewModel: mainModel) else {
            finishClosure?(nil)
            return
        }

        guard let url = mainCatalog.url ?? mainModel.urlString(),
            isClean || mainModel.sections.isEmpty && mainModel.audios.isEmpty else {
            mainModel.reload(catalog: mainCatalog)
            finishClosure?(nil)
            return
        }

        RestApi.instance.requestRT(usingUrl: url, type: RTCatalog.self) { [weak self] error, catalog in

            guard let self = self else { return }
            guard error == nil, let catalog = catalog else {
                DispatchQueue.main.async {
                    finishClosure?(error)
                }
                return
            }
            mainCatalog += catalog
            self.mainModel?.reload(catalog: mainCatalog)
            self.mainModel?.isCollapsed = false
            self.lastUpdated = RTCatalog.lastUpdated()
            catalog.remove()
            
            CoreDataManager.instance.save()
        
            DispatchQueue.main.async {
                finishClosure?(nil)
            }
        }
    }

    internal override func expanding(model: SectionViewModel?, section: Int, incrementPage: Bool, startClosure: (() -> Void)? = nil, finishClosure: ((_ error: JFError?) -> Void)? = nil) {

        guard var dbSection = mainCatalogFromDb(sectionViewModel: model),
            let sectionModel = model else {
            finishClosure?(nil)
            return
        }
        dbSection.isCollapsed = !dbSection.isCollapsed
        sectionModel.reload(catalog: dbSection)

        guard let url = dbSection.url ?? sectionModel.urlString(),
            sectionModel.audios.isEmpty,
            sectionModel.sections.isEmpty else {
            finishClosure?(nil)
            return
        }

        RestApi.instance.requestRT(usingUrl: url, type: RTCatalog.self) { [weak self] error, catalog in
           
            guard let self = self else { return }
            guard error == nil,
                let catalog = catalog,
                let mainModel = self.mainModel
            else {
                DispatchQueue.main.async {
                    finishClosure?(error)
                }
                return
            }
            
            dbSection += catalog
            
            if let url = dbSection.url, url.isEmpty {
                dbSection.url = mainModel.urlString()
            }
            if dbSection.title == nil && catalog.title != nil {
                dbSection.title = catalog.title
            }
            if dbSection.text == nil && catalog.text != nil {
                dbSection.text = catalog.text
            }
            
            dbSection.isCollapsed = false
            sectionModel.reload(catalog: dbSection)
            
            catalog.remove()
                    
            CoreDataManager.instance.save()
            
            self.lastUpdated = RTCatalog.lastUpdated()
        }
        
        DispatchQueue.main.async {
            finishClosure?(nil)
        }
    }

    static func search(text: String = "",
                       finishClosure: ((_ error: JFError?) -> Void)? = nil) {

        guard !text.isEmpty,
            let text2Search = text.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else {
            finishClosure?(nil)
            return
        }
        let query = "/Search.ashx?query=\(text2Search)&formats=ogg,aac,mp3"
        RestApi.instance.requestRT(usingQuery: query, type: RTCatalog.self) { error, _ in
            
            if error == nil {
                CoreDataManager.instance.save()
            }
            DispatchQueue.main.async {
                finishClosure?(error)
            }
        }
    }

    private func mainCatalogFromDb(sectionViewModel: SectionViewModel?) -> RTCatalog? {
        if sectionViewModel == nil || sectionViewModel?.title.text == "Browse" {
            let catalog = RTCatalog.search(byName: "Browse")?.first
            if catalog?.url == nil {
                catalog?.url = RestApi.Constants.Service.rtServer
            }
            return catalog
        }
        if let urlString = sectionViewModel?.urlString() {
            return RTCatalog.search(byUrl: urlString)
        }
        if let section = sectionViewModel?.sections.first(where: { (section) -> Bool in
            section.urlString()?.count ?? 0 > 0}),
            let urlString = section.urlString(),
            let superCatalog = RTCatalog.search(byUrl: urlString),
            (superCatalog.audioCatalog != nil || superCatalog.sectionCatalog != nil) {

            return superCatalog.audioCatalog ?? superCatalog.sectionCatalog
        } else if let section = sectionViewModel?.audios.first(where: { (section) -> Bool in
            section.urlString()?.count ?? 0 > 0}),
            let urlString = section.urlString(),
            let superCatalog = RTCatalog.search(byUrl: urlString),
            (superCatalog.audioCatalog != nil || superCatalog.sectionCatalog != nil) {

            return superCatalog.audioCatalog ?? superCatalog.sectionCatalog
        }
        return nil
    }

}
