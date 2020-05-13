//
//  ArchiveDoc+.swift
//  LDLARadio
//
//  Created by fox on 12/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreData
import Groot

public extension ArchiveDoc {

    override func didChangeValue(forKey key: String) {
        if key == "creatorTrf" {
            setPrimitiveValue(parseField(field: creatorTrf), forKey: "creator")
        } else if key == "subjectTrf" {
            setPrimitiveValue(parseField(field: subjectTrf), forKey: "subject")
        } else if key == "descriptTrf" {
            setPrimitiveValue(parseField(field: descriptTrf), forKey: "descript")
        }
        super.didChangeValue(forKey: key)
    }
}

extension ArchiveDoc {
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

    func extractFiles() {
        detail?.extractFiles()
    }

}

extension ArchiveDoc: Sectionable {
    var sectionIdentifier: String {
        return identifier ?? "#\(arc4random())"
    }
    var titleText: String? {
        return title
    }
    
    var subTitleText: String? {
        return String.join(array: [subject, creator], separator: ". ")
    }
    
    var detailText: String? {
        return descript
    }
    
    var infoText: String? {
        return String.join(array: [response?.meta?.collection?.titleText, title, subject, creator, descript, publicDate], separator: "\n")
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
        return false
    }
    
    var parentId: String? {
        return response?.meta?.identifier ?? response?.meta?.collectionIdentifier
    }
    
    var sectionDetailText: String? {
        return descript
    }
    
    var queryUrl: URL? {
        if let queryUrl = urlString()?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) {
            return URL(string: queryUrl)
        }
        return nil
    }
    var content: ([ArchiveFile], [ArchiveFile]) {
        if let array = detail?.archiveFiles?.array as? [ArchiveFile], array.isEmpty == false {
            return ([], array)
        }
        return ([], [])
    }

}

extension ArchiveDoc: Modellable {

    static func all() -> [ArchiveDoc]? {
        return all(predicate: nil,
                   sortDescriptors: [NSSortDescriptor(key: "title", ascending: false)])
            as? [ArchiveDoc]
    }
}

extension ArchiveDoc: Searchable {

    /// Fetch an object by url
    static func search(byUrl url: String?) -> ArchiveDoc? {
        guard let url = url else { return nil }
        guard let context = RestApi.instance.context else { fatalError() }
        let req = NSFetchRequest<ArchiveDoc>(entityName: "ArchiveDoc")
        req.predicate = NSPredicate(format: "urlString() = %@", url)
        let object = try? context.fetch(req).first
        return object
    }

    /// Returns the streams for a given name.
    static func search(byName name: String?) -> [ArchiveDoc]? {
        guard let context = RestApi.instance.context else { fatalError() }
        guard let name = name else { return nil }
        let req = NSFetchRequest<ArchiveDoc>(entityName: "ArchiveDoc")
        req.predicate = NSPredicate(format: "title = %@ OR title CONTAINS[cd] %@ OR descript = %@ OR descript CONTAINS[cd] %@ OR identifier = %@ OR identifier CONTAINS[cd] %@ OR subject = %@ OR subject CONTAINS[cd] %@ OR creator = %@ OR creator CONTAINS[cd] %@", name, name, name, name, name, name, name, name, name, name)
        req.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false), NSSortDescriptor(key: "identifier", ascending: true)]
        let array = try? context.fetch(req)
        return array
    }

    /// Fetch an object by id
    static func search(byIdentifier id: String?) -> ArchiveDoc? {
        guard let context = RestApi.instance.context else { fatalError() }
        guard let id = id else { return nil }
        let req = NSFetchRequest<ArchiveDoc>(entityName: "ArchiveDoc")
        req.predicate = NSPredicate(format: "identifier = %@", id)
        let array = try? context.fetch(req)
        return array?.first
    }

}
