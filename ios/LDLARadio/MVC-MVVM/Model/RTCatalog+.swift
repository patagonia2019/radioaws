//
//  RTCatalog+.swift
//  LDLARadio
//
//  Created by fox on 13/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreData

extension RTCatalog: Modellable {
    /// Function to obtain all the catalogs
    static func all() -> [RTCatalog]? {
        return all(predicate: nil,
                   sortDescriptors: [NSSortDescriptor(key: "title", ascending: false), NSSortDescriptor(key: "text", ascending: true)])
            as? [RTCatalog]
    }

}

extension RTCatalog: Searchable {

    /// Returns the streams for a given name.
    static func search(byName name: String?) -> [RTCatalog]? {
        guard let context = RestApi.instance.context else { fatalError() }
        guard let name = name else { return nil }
        let req = NSFetchRequest<RTCatalog>(entityName: "RTCatalog")
        req.predicate = NSPredicate(format: "title = %@ OR title CONTAINS[cd] %@ OR text = %@ OR text CONTAINS[cd] %@ OR currentTrack = %@ OR currentTrack CONTAINS[cd] %@ OR currentTrack = %@ OR currentTrack CONTAINS[cd] %@", name, name, name, name, name, name, name, name)
        req.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false), NSSortDescriptor(key: "text", ascending: true)]
        let array = try? context.fetch(req)
        return array
    }

}

extension RTCatalog {

    override public func didChangeValue(forKey key: String) {
        if key == "reliabilityTrf" {
            setPrimitiveValue(parseField(field: reliabilityTrf), forKey: "reliability")
        } else if key == "bitrateTrf" {
            setPrimitiveValue(parseField(field: bitrateTrf), forKey: "bitrate")
        }
        super.didChangeValue(forKey: key)

    }

    /// returns the title or text of the catalog
    func titleAndText() -> String? {
        var str = [String]()
        if let text = text {
            str.append(text)
        }
        if let title = title, !str.contains(title) {
            str.append(title)
        }
        return str.joined(separator: ". ")
    }

    /// Builds a tree of hierarchy in the catalog to show in prompt view controller, smth like: "Browse > Europe > Radios"
    func titleTree() -> String {
        var str = ArraySlice<String>()
        if let t0 = sectionCatalog?.titleTree() {
            str.append(t0 + "> ")
        }
        if let t1 = titleAndText() {
            str.append(t1)
        }
//        /// Does not allow more than 30 characters in prompt
//        while str.joined().count > 30 && str.count > 1 {
//            _ = str.popFirst()
//        }
        return str.joined()
    }

    /// convenient for debug or print info about catalog
    func descript() -> String {
        var str = [String]()
        if let title = title { str.append(title) }
        if let url = url { str.append(url) }
        if let key = key { str.append(key) }
        if let sections = sections { str.append("\(sections) sections") }
        if let audios = audios { str.append("\(audios.count) audios") }
        return str.joined(separator: ", ")
    }

    /// Determine if the catalog is about text information
    func isOnlyText() -> Bool {
        guard let sections = sections, let audios = audios else { return false }
        return type == "text" || (sections.isEmpty && audios.isEmpty && title != "Browse")
    }

    /// Determine if the catalog is about audio information
    func isAudio() -> Bool {
        return type == "audio" || element == "audio" || formats == "mp3"
    }

    /// Determine if the catalog is about link information
    func isLink() -> Bool {
        return type == nil || type == "link"
    }

    /// Fetch an object by url
    static func search(byUrl url: String?) -> RTCatalog? {
        guard let context = RestApi.instance.context else { fatalError() }
        guard let url = url else { return nil }
        let req = NSFetchRequest<RTCatalog>(entityName: "RTCatalog")
        req.predicate = NSPredicate(format: "url = %@", url)
        req.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false), NSSortDescriptor(key: "text", ascending: true)]
        let array = try? context.fetch(req)
        return array?.first
    }

}
