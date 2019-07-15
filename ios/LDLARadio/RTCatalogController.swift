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
    
    var mainCatalog : CatalogViewModel? = nil

    init(withCatalog catalog: CatalogViewModel) {
        mainCatalog = catalog
    }
    
    func refresh(startClosure: (() -> Void)? = nil,
                 finishClosure: ((_ error: Error?) -> Void)? = nil) {
        startClosure?()
        
        RTCatalogManager.instance.clean()
        
        RTCatalogManager.instance.setup(url: mainCatalog?.url?.absoluteString) { (error) in
            if error != nil {
                CoreDataManager.instance.rollback()
            }
            else {
                CoreDataManager.instance.save()
            }
//            self.catalogViewModels = RTCatalogManager.instance.catalogs() ?? [CatalogViewModel]()
            if self.mainCatalog == nil {
//                self.mainCatalog = RTCatalogManager.instance.mainCatalog
            }
            
            DispatchQueue.main.async {
                finishClosure?(error)
            }
        }
    }

}
