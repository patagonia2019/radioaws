//
//  RadioController.swift
//  LDLARadio
//
//  Created by fox on 22/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Foundation
import JFCore

class RadioController: BaseController {
    
    var models = [AudioViewModel]()
    
    override init() { }

    init(withStreams streams: [Stream]?) {
        super.init()
        models = streams?.map({ AudioViewModel(stream: $0) }) ?? [AudioViewModel]()
    }
    
    override func numberOfRows(inSection section: Int) -> Int {
        return models.count
    }
    
    override func model(forSection section: Int, row: Int) -> Any? {
        if row < models.count {
            return models[row]
        }
        return nil
    }
    
    override func heightForRow(at section: Int, row: Int) -> CGFloat {
        return CGFloat(AudioViewModel.height())
    }
    
    private func updateModels() {
        if let streams = Stream.all()?.filter({ (stream) -> Bool in
            return stream.url?.count ?? 0 > 0
        }) {
            models = streams.map({ AudioViewModel(stream: $0) })
        }
        lastUpdated = Stream.lastUpdated()
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

            StreamListManager.instance.clean()
            StationListManager.instance.clean()
            CityListManager.instance.clean()
            
            StreamListManager.instance.setup { (error) in
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
