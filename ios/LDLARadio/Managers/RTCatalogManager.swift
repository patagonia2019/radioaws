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
    
    /// Notification for when download progress has changed.
    static let didLoadNotification = NSNotification.Name(rawValue: "RTCatalogManager.didLoadNotification")
    
    static let errorNotification = NSNotification.Name(rawValue: "RTCatalogManager.errorNotification")
    
    /// The internal array of Stream structs.
    private var catalog : RTCatalog? = nil

    // MARK: Initialization
    
//    init() {
//        update(tryRequest: true)
//    }
//
//    mutating func catalogs() -> [CatalogViewModel]? {
//        update()
//        return nil
//    }
//
//    mutating func update(tryRequest: Bool = false) {
//        // try memory
//        if catalog == nil {
//            // Try the database
//            catalog = catalogFetch()
//        }
//        // try request
//        if tryRequest && catalog == nil {
//            setup()
//        }
//    }
    
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
        RestApi.instance.requestRT(usingUrl: url, type: RTCatalog.self) { error, catalog in
            if finish == nil {
                guard let error = error else {
                    NotificationCenter.default.post(name: RTCatalogManager.didLoadNotification, object: nil)
                    return
                }
                let jerror = JFError(code: 101,
                                     desc: "failed to get catalog",
                                     reason: "something get wrong on request catalog", suggestion: "\(#file):\(#line):\(#column):\(#function)",
                    underError: error as NSError?)
                NotificationCenter.default.post(name: RTCatalogManager.errorNotification, object: jerror)
                return
            }
            if catalog?.title == nil {
                catalog?.title = catalog?.text
            }
            finish?(error, catalog)
        }
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
