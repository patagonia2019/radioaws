//
//  AudioPlay+.swift
//  LDLARadio
//
//  Created by fox on 19/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreData
import CloudKit
import AVKit
import JFCore

extension AudioPlay : Modellable {
    
    static func all() -> [AudioPlay]? {
        return all(predicate: nil, sortDescriptors: nil) as? [AudioPlay]
    }
    
}


extension AudioPlay : Searchable {
    
    /// Fetch an object by url
    static func search(byUrl url: String?) -> AudioPlay? {
        guard let url = url else { return nil }
        guard let context = RestApi.instance.context else { fatalError() }
        let req = NSFetchRequest<AudioPlay>(entityName: "AudioPlay")
        req.predicate = NSPredicate(format: "urlString = %@", url)
        let object = try? context.fetch(req).first
        return object
    }
    
    /// Fetch an object by id
    static func search(byIdentifier id: String?) -> AudioPlay? {
        guard let context = RestApi.instance.context else { fatalError() }
        guard let id = id else { return nil }
        let req = NSFetchRequest<AudioPlay>(entityName: "AudioPlay")
        req.predicate = NSPredicate(format: "id = %@", id)
        let array = try? context.fetch(req)
        return array?.first
    }
    
    /// Returns the streams for a given name.
    static func search(byName name: String?) -> [AudioPlay]? {
        guard let context = RestApi.instance.context else { fatalError() }
        guard let name = name else { return nil }
        let req = NSFetchRequest<AudioPlay>(entityName: "AudioPlay")
        req.predicate = NSPredicate(format: "title = %@ OR title CONTAINS[cd] %@ OR subTitle = %@ OR subTitle CONTAINS[cd] %@ OR detail = %@ OR detail CONTAINS[cd] %@", name, name, name, name, name, name)
        let array = try? context.fetch(req)
        return array
    }

}


extension AudioPlay {
    /// Create AudioPlay entity programatically
    static func create() -> AudioPlay? {
        guard let context = RestApi.instance.context else { fatalError() }
        guard let entity = NSEntityDescription.entity(forEntityName: "AudioPlay", in: context) else {
            fatalError()
        }
        let audioPlay = NSManagedObject(entity: entity, insertInto: context) as? AudioPlay
        return audioPlay
    }
    
    static func create(record: CKRecord) -> AudioPlay? {
        
        var audioPlay : AudioPlay? = AudioPlay.search(byUrl: record["url"])
        
        if audioPlay == nil {
            audioPlay = AudioPlay.create()
        }
        
        if audioPlay == nil {
            return nil
        }
        
        audioPlay?.detail = record["detail"] as? String
        audioPlay?.id = record["id"] as? String
        audioPlay?.placeholder = record["placeholder"] as? String
        audioPlay?.subTitle = record["subTitle"] as? String
        audioPlay?.thumbnailUrl = record["thumbnailUrl"] as? String
        audioPlay?.title = record["title"] as? String
        audioPlay?.urlString = record["url"] as? String
        audioPlay?.section = record["section"] as? String
        audioPlay?.recordID = record.recordID.recordName
        audioPlay?.descript = record["descript"] as? String
        audioPlay?.currentTime = record["descript"] as? Double ?? 0.0
        audioPlay?.hasDuration = record["hasDuration"] as? Bool ?? false

        return audioPlay
    }
    
    
}

extension AudioPlay {
    /// Using += as a overloading assignment operator for AudioViewModel's in AudioPlay entities
    static func +=(audioPlay: inout AudioPlay, audioViewModel: AudioViewModel) {
        audioPlay.detail = audioViewModel.detail.text
        audioPlay.id = audioViewModel.id
        audioPlay.placeholder = audioViewModel.placeholderImageName
        audioPlay.subTitle = audioViewModel.subTitle.text
        audioPlay.thumbnailUrl = audioViewModel.thumbnailUrl?.absoluteString
        audioPlay.title = audioViewModel.title.text
        audioPlay.urlString = audioViewModel.url?.absoluteString
        audioPlay.section = audioViewModel.section
        audioPlay.descript = audioViewModel.text
    }
    
    /// Use the url of the stream/audio as an AVURLAsset
    func urlAsset() -> AVURLAsset? {
        guard let urlString = urlString,
            let url = URL(string: urlString) else { return nil }
        return AVURLAsset(url: url)
    }
    
}

