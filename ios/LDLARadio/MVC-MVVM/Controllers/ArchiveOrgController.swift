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

extension Controllable where Self : ArchiveOrgController {
    func model(inSection section: Int) -> CatalogViewModel? {
        if section < models.count {
            let model = models[section]
            return model
        }
        return nil
    }
}


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
        var count : Int = 0
        if section < models.count {
            let model = models[section]
            if model.isExpanded == false {
                return 0
            }
            count = model.audios.count
        }
        return count > 0 ? count : 1
    }
    
    override func model(forSection section: Int, row: Int) -> Any? {
        if section < models.count {
            let model = models[section]
            if row < model.audios.count {
                return model.audios[row]
            }
        }
        return nil
    }
    
    override func titleForHeader(inSection section: Int) -> String? {
        if section < models.count {
            return models[section].title.text
        }
        return nil
    }
    
    override func heightForHeader(at section: Int) -> CGFloat {
        return CGFloat(CatalogViewModel.cellheight)
    }
    
    override func heightForRow(at section: Int, row: Int) -> CGFloat {
        if let model = model(forSection: section, row: row) as? AudioViewModel {
            return CGFloat(model.height())
        }
        return 0
    }
    
    private func updateModels() {

        if let collections = ArchiveCollection.all() {
            func isExpanded(ac: ArchiveCollection?) -> Bool {
                return models.filter { (catalog) -> Bool in
                    if let identifier = ac?.identifier {
                        let queryUrl = "\(RestApi.Constants.Service.archServer)/details/\(identifier)"
                        return (catalog.isExpanded ?? false) && queryUrl == catalog.urlString()
                    }
                    return false
                    }.count > 0
            }
            models = collections.map({ CatalogViewModel(archiveCollection: $0, isAlreadyExpanded: isExpanded(ac: $0)) })
        }
        lastUpdated = ArchiveCollection.lastUpdated()
    }
    

    override func privateRefresh(isClean: Bool = false,
                                 prompt: String = "Archive.org",
                                 finishClosure: ((_ error: JFError?) -> Void)? = nil)
    {
        if isClean == false {
            updateModels()
            if models.count > 0 {
                finishClosure?(nil)
                return
            }
        }
        
        RestApi.instance.context?.performAndWait {
            
            ArchiveCollection.clean()
            
            RestApi.instance.requestLDLA(usingQuery: "/archive_org_audios.json", type: Many<ArchiveCollection>.self) { error, _ in
                
                if error != nil {
                    CoreDataManager.instance.rollback()
                }
                else {
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
            changeCatalogBookmark(model: model)
        }
    }
    
//    func expand(model: CatalogViewModel?, section: Int,
//                finishClosure: ((_ error: JFError?) -> Void)? = nil) {
//        RestApi.instance.context?.performAndWait {
//            self.expanding(model: model, section: section, finishClosure: finishClosure)
//        }
//    }
//
//    private func expanding(model: CatalogViewModel?, section: Int, finishClosure: ((_ error: JFError?) -> Void)? = nil) {
//
//        if let isExpanded = model?.isExpanded {
//            models[section].isExpanded = !isExpanded
//        }
//
//        finishClosure?(nil)
//    }
    func expand(model: CatalogViewModel?, section: Int,
                startClosure: (() -> Void)? = nil,
                finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        RestApi.instance.context?.performAndWait {
            self.expanding(model: model, section: section, startClosure: startClosure, finishClosure: finishClosure)
        }
    }
    
    private func expanding(model: CatalogViewModel?, section: Int, startClosure: (() -> Void)? = nil, finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        
        let archiveCollection = ArchiveCollection.search(byName: model?.title.text)?.first

        archiveCollection?.isExpanded = !(archiveCollection?.isExpanded ?? false)
        
        let url = archiveCollection?.searchUrlString()
        if url == nil {
            lastUpdated = RTCatalog.lastUpdated()
            finishClosure?(nil)
            return
        }
        
        RestApi.instance.context?.performAndWait {
            
            ArchiveCollection.clean()
            
            RestApi.instance.requestARCH(usingUrl: url, type: ArchiveMeta.self) { error, meta in

                archiveCollection?.meta = meta

                if error != nil {
                    CoreDataManager.instance.rollback()
                }
                else {
                    CoreDataManager.instance.save()
                }
                
                self.updateModels()
                
                DispatchQueue.main.async {
                    finishClosure?(error)
                }
            }
        }

        
    }


}
