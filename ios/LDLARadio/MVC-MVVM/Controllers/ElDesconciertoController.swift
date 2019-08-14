//
//  ElDesconciertoController.swift
//  LDLARadio
//
//  Created by fox on 28/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import JFCore
import AlamofireCoreData

class ElDesconciertoController: BaseController {
    
    fileprivate var models = [CatalogViewModel]()
    
    override init() { }
    
    override func numberOfSections() -> Int {
        return models.count
    }
    
    override func prompt() -> String {
        return AudioViewModel.ControllerName.desconcierto.rawValue
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
    
    override func modelInstance(inSection section: Int) -> CatalogViewModel? {
        if section < models.count {
            let model = models[section]
            return model
        }
        return nil
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
        return CGFloat(CatalogViewModel.cellheight) * 1.5
    }

    override func heightForRow(at section: Int, row: Int) -> CGFloat {
        if let model = model(forSection: section, row: row) as? AudioViewModel {
            return CGFloat(model.height())
        }
        return 0
    }
    
    private func updateModels() {
        if let streams = Desconcierto.all()?.filter({ (stream) -> Bool in
            return stream.streamUrl1?.count ?? 0 > 0
        }) {
            func isExpanded(des: Desconcierto?) -> Bool {
                return models.filter { (catalog) -> Bool in
                    return (catalog.isExpanded ?? false) && des?.date == catalog.title.text
                }.count > 0
            }
            models = streams.map({ CatalogViewModel(desconcierto: $0, isAlreadyExpanded: isExpanded(des: $0)) }).filter({ (model) -> Bool in
                return model.urlString()?.count ?? 0 > 0
            })
        }
        lastUpdated = Desconcierto.lastUpdated()
    }
    
    override func privateRefresh(isClean: Bool = false,
                                 prompt: String,
                                 finishClosure: ((_ error: JFError?) -> Void)? = nil) {

        if isClean == false {
            updateModels()
            if models.count > 0 {
                finishClosure?(nil)
                return
            }
        }
        
        RestApi.instance.context?.performAndWait {
            
            Desconcierto.clean()
            
            RestApi.instance.requestLDLA(usingQuery: "/desconciertos.json", type: Many<Desconcierto>.self) { error, _ in
                
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
    
    internal override func expanding(model: CatalogViewModel?, section: Int, startClosure: (() -> Void)? = nil, finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        
        if let isExpanded = model?.isExpanded {
            models[section].isExpanded = !isExpanded
        }
        
        finishClosure?(nil)
    }

}
