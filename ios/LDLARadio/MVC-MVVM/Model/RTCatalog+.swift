//
//  RTCatalog+.swift
//  LDLARadio
//
//  Created by fox on 13/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreData
import UIKit

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

extension RTCatalog: Audible {
    var identifier: String {
        return guideId ?? presetId ?? genreId ?? "#\(arc4random())"
    }
    
    var titleText: String? {
        return titleAndText
    }
    
    var subTitleText: String? {
        return subtext
    }
    
    var detailText: String? {
        if let currentTrack = currentTrack,
            subTitleText != currentTrack,
            let playing = playing {
            return [playing, currentTrack].joined(separator: "\n")
        }
        return playing ?? currentTrack ?? audioCatalog?.titleAndText ?? sectionCatalog?.titleAndText
    }
    
    var infoText: String? {
        return String.join(array: [subTitleText, currentTrack != subTitleText ? currentTrack : nil, bitrate, formats], separator: ". ")
    }
    
    var placeholderImage: UIImage? {
        let imageName = RTCatalog.placeholderImageName
        return UIImage.init(named: imageName)
    }
    
    var portraitUrl: URL? {
        if let imageUrl = image?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) {
            return URL(string: imageUrl)
        }
        return nil
    }
    
    var audioUrl: URL? {
        if let audioUrl = url?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) {
            return URL(string: audioUrl)
        }
        return nil
    }
}

public extension RTCatalog {

    override func didChangeValue(forKey key: String) {
        if key == "reliabilityTrf" {
            setPrimitiveValue(parseField(field: reliabilityTrf), forKey: "reliability")
        } else if key == "bitrateTrf" {
            setPrimitiveValue(parseField(field: bitrateTrf), forKey: "bitrate")
        }
        super.didChangeValue(forKey: key)
    }
}

extension RTCatalog {

    /// returns the title or text of the catalog
    var titleAndText: String? {
        return String.join(array: [text, title], separator: ". ")
    }

    /// Builds a tree of hierarchy in the catalog to show in prompt view controller, smth like: "Browse \n Europe \n Radios"
    var titleTree: String? {
        return String.join(array: [sectionCatalog?.titleTree, titleAndText], separator: " > ")
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
