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

extension RTCatalog: Sectionable {
    
    var sectionIdentifier: String {
        // reuse same id
        return audioIdentifier
    }
    
    var collapsed: Bool {
        return isCollapsed
    }
    
    var parentId: String? {
        if let parent = sectionCatalog ?? audioCatalog {
            return parent.guideId ?? parent.genreId ?? parent.presetId
        }
        return nil
    }
    
    var sectionDetailText: String? {
        var str = [String]()
        str.append("\n")
        if let n = sections?.count, n > 0 {
            str.append("(\(n) catalog\(n == 1 ? "" : "s"))")
        }
        if let n = audios?.count, n > 0 {
            str.append("(\(n) stream\(n == 1 ? "" : "s"))")
        }
        return str.joined()
    }
    
    var queryUrl: URL? {
        if let queryUrl = url?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) {
            return URL(string: queryUrl)
        }
        return nil
    }
    
    var content: ([RTCatalog], [RTCatalog]) {
        var all = [RTCatalog]()
        var fixedSections = [RTCatalog]()
        var fixedAudios = [RTCatalog]()
        if let sectionsOfCatalog = sections?.array as? [RTCatalog] {
            all.append(contentsOf: sectionsOfCatalog)
        }
        if let audiosOfCatalog = audios?.array as? [RTCatalog] {
            all.append(contentsOf: audiosOfCatalog)
        }
        for element in all {
            if element.moderated {
                if element.isAudio() {
                    fixedAudios.append(element)
                } else {
                    fixedSections.append(element)
                }
                continue
            }
            element.moderated = true
            let audioCatalog = element.audioCatalog ?? element.sectionCatalog ?? self
            let sectionCatalog = element.sectionCatalog ?? element.audioCatalog ?? self
            if element.isAudio() {
                element.audioCatalog = audioCatalog
                element.sectionCatalog = nil
                fixedAudios.append(element)
            } else {
                element.audioCatalog = nil
                element.sectionCatalog = sectionCatalog
                fixedSections.append(element)
            }
        }
        return (fixedSections.sorted(by: { (c1, c2) -> Bool in
            c1 < c2
        }), fixedAudios.sorted(by: { (c1, c2) -> Bool in
            c1 < c2
        }))
    }
}

extension RTCatalog: Audible {
    
    var audioIdentifier: String {
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

    /// Builds a tree of hierarchy in the catalog to show in prompt view controller, smth like: "Browse > Europe > Radios"
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
        return (type == "audio" || element == "audio" || formats == "mp3") && !(url?.isEmpty ?? true)
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
    
    static func < (left: RTCatalog, right: RTCatalog) -> Bool {
        guard let lt = left.title ?? left.text,
            let rt = right.title ?? right.text else {
            return false
        }
        return lt < rt
    }

    var containsSections: Bool {
        return !(sections?.isEmpty ?? true)
    }
    
    var containsAudios: Bool {
        return !(audios?.isEmpty ?? true)
    }
    
    /// Using += as a overloading assignment operator
    static func += (left: inout RTCatalog, right: RTCatalog) {
        // RTNode
        left.element = right.element ?? left.element
        left.text = right.text ?? left.text
        left.type = right.type ?? left.type
        left.url = right.url ?? left.url

        // RTCatalog
        left.bitrate = right.bitrate ?? left.bitrate
        left.bitrateTrf = right.bitrateTrf ?? left.bitrateTrf
        left.currentTrack = right.currentTrack ?? left.currentTrack
        left.formats = right.formats ?? left.formats
        left.genreId = right.genreId ?? left.genreId
        left.guideId = right.guideId ?? left.guideId
        left.image = right.image ?? left.image
        left.isCollapsed = right.isCollapsed
        left.isDirect = right.isDirect
        left.isHlsAdvanced = right.isHlsAdvanced ?? left.isHlsAdvanced
        left.item = right.item ?? left.item
        left.itemToken = right.itemToken ?? left.itemToken
        left.key = right.key ?? left.key
        left.liveSeekStream = right.liveSeekStream ?? left.liveSeekStream
        left.mediaType = right.mediaType ?? left.mediaType
        left.nextAction = right.nextAction ?? left.nextAction
        left.nextGuideId = right.nextGuideId ?? left.nextGuideId
        left.nowPlayingId = right.nowPlayingId ?? left.nowPlayingId
        left.playerHeight = right.playerHeight
        left.playerWidth = right.playerWidth
        left.playing = right.playing ?? left.playing
        left.playingImage = right.playingImage ?? left.playingImage
        left.position = right.position
        left.presetId = right.presetId ?? left.presetId
        left.reliability = right.reliability ?? left.reliability
        left.reliabilityTrf = right.reliabilityTrf ?? left.reliabilityTrf
        left.subtext = right.subtext ?? left.subtext
        left.title = right.title ?? left.title
        left.audios = right.audios ?? left.audios
        left.sections = right.sections ?? left.sections
        if right.audioCatalog != nil {
            left.audioCatalog = right.audioCatalog
        }
        if right.sectionCatalog != nil {
            left.sectionCatalog = right.sectionCatalog
        }
        if left.title == "Browse" || right.title == "Browse" {
            left.url = RestApi.Constants.Service.rtServer
        }
    }
}
