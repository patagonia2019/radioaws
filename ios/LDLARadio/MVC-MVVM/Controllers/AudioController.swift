//
//  AudioController.swift
//  LDLARadio
//
//  Created by fox on 22/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Foundation
import JFCore

class AudioController: BaseController {
    
    var models = [AudioViewModel]()
    
    override init() { }

    init(withStreams streams: [Stream]?) {
        super.init()
        models = streams?.map({ AudioViewModel(stream: $0) }) ?? [AudioViewModel]()
        lastUpdated = streams?.first?.updatedAt
    }
    
    override func numberOfRows(inSection section: Int) -> Int {
        return models.count
    }
    
    override func model(forSection section: Int, row: Int) -> Any? {
        return models[row]
    }
    
    override func heightForRow(at section: Int, row: Int) -> CGFloat {
        return CGFloat(AudioViewModel.height())
    }
    
    private func updateModels() {
        if models.count == 0,
            let streams = Stream.all() {
            lastUpdated = streams.first?.updatedAt
            models = streams.map({ AudioViewModel(stream: $0) })
        }
    }
    
    override func privateRefresh(isClean: Bool = false,
                                prompt: String,
                                startClosure: (() -> Void)? = nil,
                                finishClosure: ((_ error: Error?) -> Void)? = nil) {
        
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
        
        CoreDataManager.instance.taskContext?.performAndWait {

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
