//
//  RadioTimeController.swift
//  LDLARadio
//
//  Created by fox on 13/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import JFCore

extension Controllable where Self : RadioTimeController {
    func modelInstance(inSection section: Int) -> CatalogViewModel? {
        if let model = mainModel,
            section < model.sections.count {
            return model.sections[section]
        }
        return mainModel
    }
}

class RadioTimeController: BaseController {
    
    fileprivate var mainModel : CatalogViewModel? = nil

    override init() { }

    init(withCatalogViewModel catalogViewModel: CatalogViewModel?) {
        mainModel = catalogViewModel
    }
    
    override func numberOfSections() -> Int {
        print("\n")
        var n = 0
        if let model = mainModel {
            n = model.sections.count
            n += (model.audios.count > 0 ? 1 : 0)
        }
        return n
    }
    
    override func titleForHeader(inSection section: Int) -> String? {
        return ""
    }
    
    override func numberOfRows(inSection section: Int) -> Int {
        var count : Int = 0
        if let model = mainModel {
            if section < model.sections.count {
                let subModel = model.sections[section]
                print ("\(subModel.title) \((subModel.isExpanded ?? false) ? "-" : "+")")
                if subModel.isExpanded == false {
                    return 0
                }
                count = subModel.sections.count + subModel.audios.count
            }
            else {
                count = model.audios.count
            }
        }
        return count > 0 ? count : 1
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
            }
            else {
                if row < model.audios.count {
                    return model.audios[row]
                }
            }
        }
        return nil
    }
    
    override func heightForHeader(at section: Int) -> CGFloat {
        return CGFloat(CatalogViewModel.cellheight)
    }

    override func heightForRow(at section: Int, row: Int) -> CGFloat {
        let subModel = model(forSection: section, row: row)
        if subModel is AudioViewModel {
            return CGFloat(AudioViewModel.cellheight)
        }
        return CGFloat(CatalogViewModel.cellheight)
    }
    
    override func prompt() -> String {
        return mainModel?.tree ?? mainModel?.title.text ?? "Browse"
    }
    
    override func privateRefresh(isClean: Bool = false,
                 prompt: String = AudioViewModel.ControllerName.radioTime.rawValue,
                 finishClosure: ((_ error: JFError?) -> Void)? = nil) {

        let mainCatalog = mainCatalogFromDb(mainCVM: mainModel)

        var resetInfo = false
        if isClean {
            if (mainModel == nil || mainModel?.title.text == "Browse") && mainCatalog?.title == "Browse" {
                resetInfo = true
            }
            else if (mainCatalog?.url ?? mainModel?.urlString()) != nil {
                resetInfo = true
            }
        }
    

        if resetInfo == false {
            if mainModel?.sections.count ?? 0 > 0 || mainModel?.audios.count ?? 0 > 0 {
                
                mainModel = CatalogViewModel(catalog: mainCatalog)

                lastUpdated = RTCatalog.lastUpdated()
                finishClosure?(nil)
                return
            }
            
            if  mainCatalog != nil &&
                (mainCatalog?.sections?.count ?? 0 > 0 || mainCatalog?.audios?.count ?? 0 > 0)  {
                mainModel = CatalogViewModel(catalog: mainCatalog)
                lastUpdated = RTCatalog.lastUpdated()
                finishClosure?(nil)
                return
            }
        }
        let url = mainCatalog?.url ?? mainModel?.urlString()
        if url == nil && (mainModel != nil && mainModel?.title.text != "Browse") {
            lastUpdated = RTCatalog.lastUpdated()
            finishClosure?(nil)
            return
        }
        
        RestApi.instance.requestRT(usingUrl: url, type: RTCatalog.self) { error, catalog in

            if error != nil {
                self.lastUpdated = RTCatalog.lastUpdated()
                DispatchQueue.main.async {
                    finishClosure?(error)
                }
                return
            }
            
            if (self.mainModel == nil || self.mainModel?.title.text == "Browse") && catalog?.title == "Browse" {
                catalog?.url = RestApi.Constants.Service.rtServer
            }
            else {
                catalog?.url = mainCatalog?.url ?? self.mainModel?.urlString()
            }
            let audios = mainCatalog?.audios
            let sections = mainCatalog?.sections
            let title = mainCatalog?.title
            let text = mainCatalog?.text
            let sectionCatalog = mainCatalog?.sectionCatalog
            let isExpanded = self.mainModel?.isExpanded
            mainCatalog?.remove()
            catalog?.sectionCatalog = sectionCatalog
            
            
            if title != nil && catalog?.title == nil {
                catalog?.title = title
            }
            if text != nil && catalog?.text == nil {
                catalog?.text = text
            }
            
            if catalog?.sections?.count ?? 0 > 0 {
                if let sections = sections?.array as? [RTCatalog] {
                    for section in sections {
                        section.sectionCatalog = catalog
                    }
                }
            }
            if catalog?.audios?.count ?? 0 > 0 {
                if let audios = audios?.array as? [RTCatalog] {
                    for audio in audios {
                        audio.audioCatalog = catalog
                    }
                }
            }
            
            CoreDataManager.instance.save()
            self.mainModel = CatalogViewModel(catalog: catalog)
            self.mainModel?.isExpanded = isExpanded ?? false
            self.lastUpdated = RTCatalog.lastUpdated()

            DispatchQueue.main.async {
                finishClosure?(error)
            }
        }
    }
    
    func changeCatalogBookmark(section: Int) {
        
        changeCatalogBookmark(model: modelInstance(inSection: section))
    }

    
    func expand(model: CatalogViewModel?, section: Int,
                startClosure: (() -> Void)? = nil,
                finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        RestApi.instance.context?.performAndWait {
            self.expanding(model: model, section: section, startClosure: startClosure, finishClosure: finishClosure)
        }
    }

    private func expanding(model: CatalogViewModel?, section: Int, startClosure: (() -> Void)? = nil, finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        
        let dbCatalog = mainCatalogFromDb(mainCVM: model)
        dbCatalog?.isExpanded = !(dbCatalog?.isExpanded ?? false)

        let mainCatalog = mainCatalogFromDb(mainCVM: mainModel)
        mainModel = CatalogViewModel(catalog: mainCatalog)
        var sectionModel = modelInstance(inSection: section)
        if let isExpanded = model?.isExpanded {
            sectionModel?.isExpanded = !isExpanded
        }
        
        if sectionModel?.audios.count ?? 0 > 0 || sectionModel?.sections.count ?? 0 > 0 {
            lastUpdated = RTCatalog.lastUpdated()
            finishClosure?(nil)
            return
        }
        
        
        if  dbCatalog != nil &&
            (dbCatalog?.sections?.count ?? 0 > 0 || dbCatalog?.audios?.count ?? 0 > 0) {
            lastUpdated = RTCatalog.lastUpdated()
            finishClosure?(nil)
            return
        }
        let url = dbCatalog?.url ?? sectionModel?.urlString()
        if url == nil && (sectionModel?.title.text != "Browse") {
            lastUpdated = RTCatalog.lastUpdated()
            finishClosure?(nil)
            return
        }
        
        RestApi.instance.requestRT(usingUrl: url, type: RTCatalog.self) { error, catalog in
            
            if error != nil {
                self.lastUpdated = RTCatalog.lastUpdated()
                DispatchQueue.main.async {
                    finishClosure?(error)
                }
                return
            }
            
            catalog?.url = dbCatalog?.url ?? sectionModel?.urlString()
            let audios = dbCatalog?.audios
            let sections = dbCatalog?.sections
            let title = dbCatalog?.title
            let text = dbCatalog?.text
            let sectionCatalog = dbCatalog?.sectionCatalog
            dbCatalog?.remove()
            catalog?.sectionCatalog = sectionCatalog
            
            
            if title != nil && catalog?.title == nil {
                catalog?.title = title
            }
            if text != nil && catalog?.text == nil {
                catalog?.text = text
            }
            
            if catalog?.sections?.count ?? 0 > 0 {
                if let sections = sections?.array as? [RTCatalog] {
                    for section in sections {
                        section.sectionCatalog = catalog
                    }
                }
            }
            if catalog?.audios?.count ?? 0 > 0 {
                if let audios = audios?.array as? [RTCatalog] {
                    for audio in audios {
                        audio.audioCatalog = catalog
                    }
                }
            }
            
            CoreDataManager.instance.save()
            
            let mainCatalog = self.mainCatalogFromDb(mainCVM: self.mainModel)
            catalog?.isExpanded = true
            self.mainModel = CatalogViewModel(catalog: mainCatalog)
            var sectionModel = self.modelInstance(inSection: section)
            sectionModel?.isExpanded = true

            self.lastUpdated = RTCatalog.lastUpdated()
            
            DispatchQueue.main.async {
                finishClosure?(error)
            }
        }
    }
    
    static func search(text: String = "",
                finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        
        if text.count == 0 {
            finishClosure?(nil)
            return
        }
        
        guard let text2Search = text.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else {
            finishClosure?(nil)
            return
        }
        let query = "/Search.ashx?query=\(text2Search)&formats=ogg,aac,mp3"
        RestApi.instance.requestRT(usingQuery: query, type: RTCatalog.self) { error, catalog in
            
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

    private func mainCatalogFromDb(mainCVM: CatalogViewModel?) -> RTCatalog? {
        if mainCVM == nil || mainCVM?.title.text == "Browse" {
            let catalog = RTCatalog.search(byName: "Browse")?.first
            if catalog?.url == nil {
                catalog?.url = RestApi.Constants.Service.rtServer
            }
            return catalog
        }
        if let urlString = mainCVM?.urlString() {
            return RTCatalog.search(byUrl: urlString)
        }
        if let section = mainCVM?.sections.first(where: { (section) -> Bool in
            return section.urlString()?.count ?? 0 > 0}),
            let urlString = section.urlString(),
            let superCatalog = RTCatalog.search(byUrl: urlString),
            (superCatalog.audioCatalog != nil || superCatalog.sectionCatalog != nil) {
            
            return superCatalog.audioCatalog ?? superCatalog.sectionCatalog
        }
        else if let section = mainCVM?.audios.first(where: { (section) -> Bool in
            return section.urlString()?.count ?? 0 > 0}),
            let urlString = section.urlString(),
            let superCatalog = RTCatalog.search(byUrl: urlString),
            (superCatalog.audioCatalog != nil || superCatalog.sectionCatalog != nil) {
            
            return superCatalog.audioCatalog ?? superCatalog.sectionCatalog
        }
        return nil
    }

    private func mainCatalogFromDb(mainCatalog: RTCatalog?) -> RTCatalog? {
        if let urlString = mainCatalog?.url {
            return RTCatalog.search(byUrl: urlString)
        }
        if let section = mainCatalog?.sections?.first(where: { (section) -> Bool in
            return (section as? RTCatalog)?.url?.count ?? 0 > 0}),
            let urlString = (section as? RTCatalog)?.url,
            let superCatalog = RTCatalog.search(byUrl: urlString),
            (superCatalog.audioCatalog != nil || superCatalog.sectionCatalog != nil) {
        
            return superCatalog.audioCatalog ?? superCatalog.sectionCatalog
        }
        else if let section = mainCatalog?.audios?.first(where: { (section) -> Bool in
            return (section as? RTCatalog)?.url?.count ?? 0 > 0}),
            let urlString = (section as? RTCatalog)?.url,
            let superCatalog = RTCatalog.search(byUrl: urlString),
            (superCatalog.audioCatalog != nil || superCatalog.sectionCatalog != nil) {
            return superCatalog.audioCatalog ?? superCatalog.sectionCatalog
        }
        return nil
    }
}
