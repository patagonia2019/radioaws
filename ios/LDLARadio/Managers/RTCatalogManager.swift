//
//  RTCatalogManager.swift
//  LDLARadio
//
//  Created by fox on 13/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Foundation
import CoreData
import AlamofireCoreData
import JFCore

struct RTCatalogManager {
    // MARK: Properties
    
    static var instance = RTCatalogManager()
    
    /// The internal array of Stream structs.
    private var catalog : RTCatalog? = nil
    
    /// Function to obtain all the albums sorted by title
    func catalogFetch() -> RTCatalog? {
        guard let context = CoreDataManager.instance.taskContext else { fatalError() }
        let req = NSFetchRequest<RTCatalog>(entityName: "RTCatalog")
        req.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false), NSSortDescriptor(key: "text", ascending: true)]
        let array = try? context.fetch(req)
        array?.forEach({ (cat) in
            print("cat \(cat.descript())\n")
        })
        return array?.first
    }
    
    // MARK: Stream access
    
    func setup(url: String? = nil, finish: ((_ error: Error?, _ catalog: RTCatalog?) -> Void)? = nil) {
        RestApi.instance.requestRT(usingUrl: url, type: RTCatalog.self, finish: finish)
    }
    
    
    
    private func save() {
        guard let context = CoreDataManager.instance.taskContext else {
            fatalError("fatal: no core data context manager")
        }
        try? context.save()
    }
    
    
    
    private func rollback() {
        guard let context = CoreDataManager.instance.taskContext else {
            fatalError("fatal: no core data context manager")
        }
        context.rollback()
    }
    
    
    func clean() {
        RTCatalog.clean()
    }
    
//    func reset() {
//        setup()
//    }
    
}
