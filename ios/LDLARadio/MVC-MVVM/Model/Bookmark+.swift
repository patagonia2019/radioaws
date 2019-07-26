//
//  Bookmark+.swift
//  LDLARadio
//
//  Created by fox on 24/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreData
import JFCore

extension Bookmark {
    
    /// Update the `updatedAt` field in the entity when the model is created
    override public func awakeFromInsert() {
        setPrimitiveValue(Date(), forKey: "updatedAt")
    }

    /// Using += as a overloading assignment operator for AudioViewModel's in Bookmark entities
    static func +=(bookmark: inout Bookmark, audioViewModel: AudioViewModel) {
        bookmark.detail = audioViewModel.detail
        bookmark.id = audioViewModel.id
        bookmark.placeholder = audioViewModel.placeholderImageName
        bookmark.subTitle = audioViewModel.subTitle
        bookmark.thumbnailUrl = audioViewModel.thumbnailUrl?.absoluteString
        bookmark.title = audioViewModel.title
        bookmark.url = audioViewModel.url?.absoluteString
        bookmark.useWeb = audioViewModel.useWeb        
    }
    
    /// Create bookmark entity programatically
    static func create() -> Bookmark? {
        guard let context = RestApi.instance.context else { fatalError() }
        guard let entity = NSEntityDescription.entity(forEntityName: "Bookmark", in: context) else {
            fatalError()
        }
        let bookmark = NSManagedObject(entity: entity, insertInto: context) as? Bookmark
        return bookmark
    }
    
    /// Fetch the most recent updatedAt date
    static func lastUpdated() -> Date? {
        guard let context = RestApi.instance.context else { fatalError() }
        let req = NSFetchRequest<Bookmark>(entityName: "Bookmark")
        req.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        return try? context.fetch(req).first?.updatedAt
    }

    /// Function to obtain all the instance of entities
    static func all() -> [Bookmark]? {
        guard let context = RestApi.instance.context else { fatalError() }
        let req = NSFetchRequest<Bookmark>(entityName: "Bookmark")
        req.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        let array = try? context.fetch(req)
        return array
    }
    
    /// Fetch an object by id
    static func fetch(id: String, url: String) -> Bookmark? {
        guard let context = RestApi.instance.context else { fatalError() }
        let req = NSFetchRequest<Bookmark>(entityName: "Bookmark")
        req.predicate = NSPredicate(format: "id = %@ and url = %@", id, url)
        let object = try? context.fetch(req).first
        return object
    }


    /// Remove current instance
    func remove() {
        guard let context = RestApi.instance.context else {
            fatalError("fatal: no core data context manager")
        }
        context.delete(self)
    }
    

}
