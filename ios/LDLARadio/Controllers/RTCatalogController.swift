//
//  RTCatalogController.swift
//  LDLARadio
//
//  Created by fox on 13/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Foundation
import JFCore

class RTCatalogController {
    
    var mainCatalog : RTCatalog? = nil
    var mainCatalogViewModel : CatalogViewModel? = nil

    init() {
    }
    
    init(withCatalogViewModel catalogViewModel: CatalogViewModel?) {
        mainCatalogViewModel = catalogViewModel
    }
    
    func refresh(isClean: Bool = false,
                 startClosure: (() -> Void)? = nil,
                 finishClosure: ((_ error: Error?) -> Void)? = nil) {
        startClosure?()
        
        if mainCatalogViewModel?.audios.count ?? 0 > 0 {
            finishClosure?(nil)
            return
        }
        
        if mainCatalog?.isAudio() ?? false {
            finishClosure?(nil)
            return
        }
        
        CoreDataManager.instance.taskContext?.perform({
            if self.mainCatalog == nil {
                if isClean {
                    RTCatalog.clean()
                }
            }
            else {
                self.mainCatalog?.remove()
            }
            self.mainCatalog = nil
            RTCatalogManager.instance.setup(url: self.mainCatalogViewModel?.urlString()) { error, catalog in
                if error != nil {
                    CoreDataManager.instance.rollback()
                    DispatchQueue.main.async {
                        finishClosure?(error)
                    }
                    return
                }
                else {
                    CoreDataManager.instance.save()
                }

                if self.mainCatalog == nil {
                    self.mainCatalog = catalog
                }
                else {
                    self.mainCatalog?.sections = catalog?.sections
                    self.mainCatalog?.audios = catalog?.audios
                    self.mainCatalog?.title = catalog?.title
                    self.mainCatalog?.url = catalog?.url
                }
                self.mainCatalogViewModel = CatalogViewModel(catalog: self.mainCatalog)
                DispatchQueue.main.async {
                    finishClosure?(error)
                }
            }

        })
        
    }

}
