//
//  ArchiveCollection+.swift
//  LDLARadio
//
//  Created by fox on 12/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension ArchiveCollection: Modellable {

    static func all() -> [ArchiveCollection]? {
        return all(predicate: nil,
                   sortDescriptors: [NSSortDescriptor(key: "title", ascending: true)])
            as? [ArchiveCollection]
    }

}

extension ArchiveCollection: Sectionable {
    
    typealias SectionModelType = ArchiveDoc
    
    var sectionIdentifier: String {
        return identifier ?? "#\(arc4random())"
    }

    var titleText: String? {
        return title
    }
    
    var subTitleText: String? {
        return subtitle
    }
    
    var detailText: String? {
        return detail
    }
    
    var infoText: String? {
        return detailText
    }
    
    var placeholderImage: UIImage? {
        return UIImage.init(named: ArchiveDoc.placeholderImageName)
    }
    
    var portraitUrl: URL? {
        if let imageUrl = thumbnailUrlString()?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) {
            return URL(string: imageUrl)
        }
        return nil
    }
    
    var collapsed: Bool {
        return isCollapsed
    }
    
    var parentId: String? {
        return nil
    }
    
    var sectionDetailText: String? {
        return "\n(\(currentPage * 10) / \(numFound) Records)"
    }
    
    var queryUrl: URL? {
        if let queryUrl = urlString()?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) {
            return URL(string: queryUrl)
        }
        return nil
    }
    
    var content: ([ArchiveDoc], [ArchiveDoc]) {
        let predicate = NSPredicate(format: "response.meta.collection.identifier = %@", sectionIdentifier)
        if let docs = ArchiveDoc.all(predicate: predicate, sortDescriptors: nil) as? [ArchiveDoc] {
            return (docs, [])
        }
        return ([], [])
    }
    
}

extension ArchiveCollection: Creational {

    /// Create bookmark entity programatically
    static func create() -> ArchiveCollection? {
        guard let context = RestApi.instance.context else { fatalError() }
        guard let entity = NSEntityDescription.entity(forEntityName: "ArchiveCollection", in: context) else {
            fatalError()
        }
        let object = NSManagedObject(entity: entity, insertInto: context) as? ArchiveCollection
        return object
    }

}

public extension ArchiveCollection {

    /// Update the `updatedAt` field in the entity when the model is created
    override func awakeFromInsert() {
        setPrimitiveValue(Date(), forKey: "updatedAt")
    }
}

extension ArchiveCollection {

    /// Fetch an object by url
    static func search(byUrl url: String?) -> ArchiveCollection? {
        guard let url = url else { return nil }
        guard let context = RestApi.instance.context else { fatalError() }
        let req = NSFetchRequest<ArchiveCollection>(entityName: "ArchiveCollection")
        req.predicate = NSPredicate(format: "urlString() = %@", url)
        let object = try? context.fetch(req).first
        return object
    }

    /// Returns the streams for a given name.
    static func search(byName name: String?) -> [ArchiveCollection]? {
        guard let context = RestApi.instance.context else { fatalError() }
        guard let name = name else { return nil }
        let req = NSFetchRequest<ArchiveCollection>(entityName: "ArchiveCollection")
        req.predicate = NSPredicate(format: "title = %@ OR title CONTAINS[cd] %@ OR subtitle = %@ OR subtitle CONTAINS[cd] %@ OR detail = %@ OR detail CONTAINS[cd] %@ OR identifier = %@ OR identifier CONTAINS[cd] %@", name, name, name, name, name, name, name, name)
        req.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false), NSSortDescriptor(key: "identifier", ascending: true)]
        let array = try? context.fetch(req)
        return array
    }

    /// Fetch an object by id
    static func search(byIdentifier id: String?) -> ArchiveCollection? {
        guard let context = RestApi.instance.context else { fatalError() }
        guard let id = id else { return nil }
        let req = NSFetchRequest<ArchiveCollection>(entityName: "ArchiveCollection")
        req.predicate = NSPredicate(format: "identifier = %@", id)
        let array = try? context.fetch(req)
        return array?.first
    }

    func thumbnailUrlString() -> String? {
        if let identifier = identifier {
            return "\(RestApi.Constants.Service.archServer)/services/img/\(identifier)"
        }
        return nil
    }

    func urlString() -> String? {
        if let identifier = identifier {
            return "\(RestApi.Constants.Service.archServer)/details/\(identifier)"
        }
        return nil
    }

    func searchCollectionUrlString(page: Int = 1) -> String? {
        if let identifier = identifier {
            return "\(RestApi.Constants.Service.archServer)/advancedsearch.php?q=collection:(\(identifier))+AND+mediatype:(audio)&fl[]=creator&fl[]=description&fl[]=downloads&fl[]=identifier&fl[]=item_size&fl[]=mediatype&fl[]=publicdate&fl[]=subject&fl[]=title&fl[]=type&sort[]=downloads+desc&sort[]=&sort[]=&rows=10&page=\(page)"

        }
        return nil
    }

    static func searchUrlString(withString string: String, page: Int = 1) -> String? {
        return "\(RestApi.Constants.Service.archServer)/advancedsearch.php?q=\(string)+AND+mediatype:(audio)&fl[]=creator&fl[]=description&fl[]=downloads&fl[]=identifier&fl[]=item_size&fl[]=mediatype&fl[]=publicdate&fl[]=subject&fl[]=title&fl[]=type&sort[]=downloads+desc&sort[]=&sort[]=&rows=10&page=\(page)"
    }

    var currentPage: Int {
        guard let page = metas?.count else {
            return 1
        }
        return page
    }

    var numFound: Int {
        guard let metas = metas?.array as? [ArchiveMeta] else {
            return 0
        }
            
        var numFound = 0
        var updatedAtMax = Date.init(timeIntervalSince1970: 0)
        for meta in metas where meta.numFound > 0 {
            if let updateAtMeta = meta.updatedAt, updatedAtMax < updateAtMeta || numFound == 0 {
                numFound = meta.numFound
                updatedAtMax = updateAtMeta
            }
        }
        return numFound
    }

    var nextPage: Int? {
        let page = currentPage + 1

        if page > numFound / 10 {
            return nil
        }
        return page
    }
}
