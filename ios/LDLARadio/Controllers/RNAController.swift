//
//  RNAController.swift
//  LDLARadio
//
//  Created by fox on 23/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Foundation
import JFCore

class RNAController: BaseController {
    
    var models = [AudioViewModel]()
    
    override init() { }
    
    init(withStreams dial: RNADial?) {
        super.init()
        models = dial?.stations?.map({ AudioViewModel(stationAm: $0 as? RNAStation) }) ?? [AudioViewModel]()
        models.append(contentsOf: dial?.stations?.map({ AudioViewModel(stationFm: $0 as? RNAStation) }) ?? [AudioViewModel]())
        lastUpdated = dial?.updatedAt
    }
    
    override func numberOfRows(inSection section: Int) -> Int {
        return models.count
    }
    
    override func catalog(forSection section: Int, row: Int) -> Any? {
        return models[row]
    }
    
    override func heightForRow(at section: Int, row: Int) -> CGFloat {
        return CGFloat(AudioViewModel.height())
    }
    
    override func prompt() -> String {
        return "Radio Nacional Argentina"
    }
    
    override func privateRefresh(isClean: Bool = false,
                                 prompt: String = "Radio Nacional Argentina",
                                 startClosure: (() -> Void)? = nil,
                                 finishClosure: ((_ error: Error?) -> Void)? = nil) {
        
        startClosure?()
        
        var resetInfo = false
        if isClean {
            resetInfo = true
        }
        
        if resetInfo == false {
            if models.count == 0,
                let dial = RNADial.all()?.first {
                
                lastUpdated = dial.updatedAt
                var tmpModels = dial.stations?.map({ AudioViewModel(stationAm: $0 as? RNAStation) }) ?? [AudioViewModel]()
                tmpModels.append(contentsOf: dial.stations?.map({ AudioViewModel(stationFm: $0 as? RNAStation) }) ?? [AudioViewModel]())
                models = tmpModels.filter({ (model) -> Bool in
                    return model.urlString() != nil
                }).sorted(by: { (model1, model2) -> Bool in
                    return model1.title < model2.title
                })
            }
            if models.count > 0 {
                finishClosure?(nil)
                return
            }
        }
        
        CoreDataManager.instance.taskContext?.performAndWait {
            
            RNAStation.clean()
            RNADial.clean()

            RestApi.instance.requestRNA(usingQuery: "/api/listar_emisoras.json", type: RNADial.self) { (error, dial) in
                if error != nil {
                    CoreDataManager.instance.rollback()
                }
                else {
                    CoreDataManager.instance.save()
                }
                                
                if let dial = RNADial.all()?.first {
                    
                    self.lastUpdated = dial.updatedAt
                    var tmpModels = dial.stations?.map({ AudioViewModel(stationAm: $0 as? RNAStation) }) ?? [AudioViewModel]()
                    tmpModels.append(contentsOf: dial.stations?.map({ AudioViewModel(stationFm: $0 as? RNAStation) }) ?? [AudioViewModel]())
                    self.models = tmpModels.filter({ (model) -> Bool in
                        return model.urlString() != nil
                    }).sorted(by: { (model1, model2) -> Bool in
                        return model1.title < model2.title
                    })
                }

                DispatchQueue.main.async {
                    finishClosure?(error)
                }
            }
        }
    }
}
