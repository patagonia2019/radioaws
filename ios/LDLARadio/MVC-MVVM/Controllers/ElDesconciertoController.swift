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

extension Controllable where Self : ElDesconciertoController {
    func model(inSection section: Int) -> CatalogViewModel? {
        if section < models.count {
            let model = models[section]
            return model
        }
        return nil
    }
}

class ElDesconciertoController: BaseController {
    
    var models = [CatalogViewModel]()
    
    override init() { }
    
    override func numberOfSections() -> Int {
        return models.count
    }
    
    override func prompt() -> String {
        return "El Desconcierto"
    }

    override func numberOfRows(inSection section: Int) -> Int {
        if section < models.count {
            let model = models[section]
            if model.isExpanded == true {
                return model.audios.count
            }
        }
        return 0
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
        return CGFloat(AudioViewModel.cellheight)
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
                                 startClosure: (() -> Void)? = nil,
                                 finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        
        startClosure?()
        
        var resetInfo = false
        if isClean {
            resetInfo = true
        }
        
        if resetInfo == false {
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
    
    func expand(model: CatalogViewModel?, section: Int,
                finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        RestApi.instance.context?.performAndWait {
            self.expanding(model: model, section: section, finishClosure: finishClosure)
        }
    }
    
    private func expanding(model: CatalogViewModel?, section: Int, finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        
        if let isExpanded = model?.isExpanded {
            models[section].isExpanded = !isExpanded
        }
        
        finishClosure?(nil)
    }

}
