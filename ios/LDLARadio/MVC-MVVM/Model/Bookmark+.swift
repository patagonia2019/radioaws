//
//  Bookmark+.swift
//  LDLARadio
//
//  Created by fox on 24/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreData

extension Bookmark : Modellable {
    
    /// Function to obtain all the albums sorted by title
    static func all() -> [Bookmark]? {
        return all(predicate: nil, sortDescriptors: [NSSortDescriptor.init(key: "title", ascending: true)]) as? [Bookmark]
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
    static func search(byName name: String?) -> Bookmark? {
        guard let context = RestApi.instance.context else { fatalError() }
        guard let name = name else { return nil }
        let req = NSFetchRequest<Bookmark>(entityName: "Bookmark")
        req.predicate = NSPredicate(format: "title = %@", name)
        let array = try? context.fetch(req)
        return array?.first
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
}

extension Bookmark {
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
    
    /// Using += as a overloading assignment operator for CatalogViewModel's in Bookmark entities
    static func +=(bookmark: inout Bookmark, catalogViewModel: CatalogViewModel) {
        bookmark.detail = catalogViewModel.detail
        bookmark.subTitle = catalogViewModel.title
        bookmark.title = catalogViewModel.tree
        bookmark.url = catalogViewModel.urlString()
    }
    
}
