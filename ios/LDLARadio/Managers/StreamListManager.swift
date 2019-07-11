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
    static let didLoadNotification = NSNotification.Name(rawValue: "StreamListManagerDidLoadNotification")

    static let errorNotification = NSNotification.Name(rawValue: "StreamListManagerErrorNotification")

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
    
    /// Function to obtain all the albums sorted by title
    func streamsFetch() -> [Stream]? {
        guard let context = CoreDataManager.instance.taskContext else { fatalError() }
        let req = NSFetchRequest<Stream>(entityName: "Stream")
        req.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let array = try? context.fetch(req)
        return array
    }

    // MARK: Stream access
    
    /// Returns the number of Streams.
    func numberOfStreams() -> Int {
        return streams.count
    }
    
    /// Returns an Stream for a given IndexPath.
    func stream(at index: Int) -> Stream {
        return streams[index]
    }

    /// Returns the streams for a given station id.
    func stream(byName name: String?) -> Stream? {
        guard let context = CoreDataManager.instance.taskContext else { fatalError() }
        guard let name = name else { return nil }
        let req = NSFetchRequest<Stream>(entityName: "Stream")
        req.predicate = NSPredicate(format: "name = %s", name)
        let array = try? context.fetch(req)
        return array?.first
    }
    
    /// Returns the streams for a given station id.
    func stream(byStation stationId: Int16?) -> [Stream]? {
        guard let context = CoreDataManager.instance.taskContext else { fatalError() }
        guard let stationId = stationId else { return nil }
        let req = NSFetchRequest<Stream>(entityName: "Stream")
        req.predicate = NSPredicate(format: "station.id = %d", stationId)
        req.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let array = try? context.fetch(req)
        return array
    }
 
    func setup() {
        RestApi.instance.request(usingQuery: "/streams.json", type: Many<Stream>.self) { error in
            guard let error = error else {
                NotificationCenter.default.post(name: StreamListManager.didLoadNotification, object: nil)
                return
            }
            let jerror = JFError(code: 101,
                                 desc: "failed to get streams.json",
                                 reason: "something get wrong on request streams.json", suggestion: "\(#file):\(#line):\(#column):\(#function)",
                underError: error as NSError?)
            NotificationCenter.default.post(name: StreamListManager.errorNotification, object: jerror)
        }
    }
}
