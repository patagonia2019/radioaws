//
//  Bookmark+.swift
//  LDLARadio
//
//  Created by fox on 24/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

extension Bookmark : Modellable {
    
    /// Function to obtain all the albums sorted by title
    static func all() -> [Bookmark]? {
        return all(predicate: nil, sortDescriptors: [NSSortDescriptor.init(key: "title", ascending: true)]) as? [Bookmark]
    }
    
    override func remove() {
        CloudKitManager.instance.remove(bookmark: self)
        super.remove()
    }

}

extension Bookmark : Searchable {
    
    /// Fetch an object by url
    static func search(byUrl url: String?) -> Bookmark? {
        guard let url = url else { return nil }
        guard let context = RestApi.instance.context else { fatalError() }
        let req = NSFetchRequest<Bookmark>(entityName: "Bookmark")
        req.predicate = NSPredicate(format: "url = %@", url)
        let object = try? context.fetch(req).first
        return object
    }
    
    /// Returns the streams for a given name.
    static func search(byName name: String?) -> [Bookmark]? {
        guard let context = RestApi.instance.context else { fatalError() }
        guard let name = name else { return nil }
        let req = NSFetchRequest<Bookmark>(entityName: "Bookmark")
        req.predicate = NSPredicate(format: "title = %@ OR title CONTAINS[cd] %@ OR subTitle = %@ OR subTitle CONTAINS[cd] %@ OR detail = %@ OR detail CONTAINS[cd] %@", name, name, name, name, name, name)
        let array = try? context.fetch(req)
        return array
    }
    
}

extension Bookmark : Creational {
    /// Create bookmark entity programatically
    static func create() -> Bookmark? {
        guard let context = RestApi.instance.context else { fatalError() }
        guard let entity = NSEntityDescription.entity(forEntityName: "Bookmark", in: context) else {
            fatalError()
        }
        let bookmark = NSManagedObject(entity: entity, insertInto: context) as? Bookmark
        return bookmark
    }
    
    static func create(record: CKRecord) -> Bookmark? {
        
        var bookmark : Bookmark? = Bookmark.search(byUrl: record["url"])

        if bookmark == nil {
            bookmark = Bookmark.create()
        }
        
        if bookmark == nil {
            return nil
        }
        
        bookmark?.detail = record["detail"] as? String
        bookmark?.id = record["id"] as? String
        bookmark?.placeholder = record["placeholder"] as? String
        bookmark?.subTitle = record["subTitle"] as? String
        bookmark?.thumbnailUrl = record["thumbnailUrl"] as? String
        bookmark?.title = record["title"] as? String
        bookmark?.url = record["url"] as? String
        bookmark?.section = record["section"] as? String
        bookmark?.recordID = record.recordID.recordName

        return bookmark
    }

}

extension Bookmark {
    /// Using += as a overloading assignment operator for AudioViewModel's in Bookmark entities
    static func +=(bookmark: inout Bookmark, audioViewModel: AudioViewModel) {
        bookmark.detail = audioViewModel.detail.text
        bookmark.id = audioViewModel.id
        bookmark.placeholder = audioViewModel.placeholderImageName
        bookmark.subTitle = audioViewModel.subTitle.text
        bookmark.thumbnailUrl = audioViewModel.thumbnailUrl?.absoluteString
        bookmark.title = audioViewModel.title.text
        bookmark.url = audioViewModel.url?.absoluteString
        bookmark.section = audioViewModel.section
        
        CloudKitManager.instance.save(bookmark: bookmark)
    }
    
    /// Using += as a overloading assignment operator for CatalogViewModel's in Bookmark entities
    static func +=(bookmark: inout Bookmark, catalogViewModel: CatalogViewModel) {
        bookmark.detail = catalogViewModel.detail.text
        bookmark.subTitle = catalogViewModel.title.text
        bookmark.title = catalogViewModel.tree
        bookmark.url = catalogViewModel.urlString()
        bookmark.section = catalogViewModel.section
        
        CloudKitManager.instance.save(bookmark: bookmark)
    }
    
}
