//
//  StreamListManager.swift
//  LDLARadio
//
//  Created by Javier Fuchs on 1/6/17.
//  Copyright © 2017 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreData
import AlamofireCoreData
import JFCore

struct StreamListManager {
    // MARK: Properties
    
    static var instance = StreamListManager()

    /// Notification for when download progress has changed.
    static let didLoadNotification = NSNotification.Name(rawValue: "StreamListManager.didLoadNotification")

    static let errorNotification = NSNotification.Name(rawValue: "StreamListManager.errorNotification")

    /// The internal array of Stream structs.
    private var streams = [Stream]()
    
    // MARK: Initialization
    
    init() {
        update(tryRequest: true)
    }
    
    mutating func update(tryRequest: Bool = false) {
        // try memory
        if streams.count == 0 {
            // Try the database
            streams = streamsFetch() ?? [Stream]()
        }
        // try request
        if tryRequest && streams.count == 0 {
            setup()
        }
    }
    
    func setup(finish: ((_ error: Error?) -> Void)? = nil) {
        RestApi.instance.requestLDLA(usingQuery: "/streams.json", type: Many<Stream>.self) { error1, _ in
            if finish == nil {
                guard let error = error1 else {
                    NotificationCenter.default.post(name: StreamListManager.didLoadNotification, object: nil)
                    return
                }
                let jerror = JFError(code: 101,
                                     desc: "failed to get stations.json",
                                     reason: "something get wrong on request stations.json", suggestion: "\(#file):\(#line):\(#column):\(#function)",
                    underError: error as NSError?)
                NotificationCenter.default.post(name: StreamListManager.errorNotification, object: jerror)
                return
            }
            guard let error1 = error1 else {
                StationListManager.instance.setup(finish: { error2 in
                    guard let error2 = error2 else {
                        CityListManager.instance.setup(finish: { error3 in
                            finish?(error3)
                        })
                        return
                    }
                    finish?(error2)
                })
                return
            }
            finish?(error1)
        }
    }
    
    
    /// Function to obtain all the albums sorted by title
    func streamsFetch() -> [Stream]? {
        guard let context = RestApi.instance.context else { fatalError() }
        let req = NSFetchRequest<Stream>(entityName: "Stream")
        req.predicate = NSPredicate(format: "listenIsWorking = true")
        req.sortDescriptors = [NSSortDescriptor(key: "station.name", ascending: true)]
        let array = try? context.fetch(req)
        return array
    }
    
    // MARK: Stream access
    
    private func save() {
        guard let context = RestApi.instance.context else {
            fatalError("fatal: no core data context manager")
        }
        try? context.save()
    }
    
    

    private func rollback() {
        guard let context = RestApi.instance.context else {
            fatalError("fatal: no core data context manager")
        }
        context.rollback()
    }


    func clean() {
        Stream.clean()
    }
    
    func reset() {
        setup()
    }

}
