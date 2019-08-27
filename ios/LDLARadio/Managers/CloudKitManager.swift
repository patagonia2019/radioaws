//
//  CloudKitManager.swift
//  LDLARadio
//
//  Created by fox on 10/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import CloudKit
import JFCore

class CloudKitManager {

    static let instance = CloudKitManager()

    let container: CKContainer
    let publicDB: CKDatabase
    let privateDB: CKDatabase
    let user: User
    var loggedIn: Bool = false
    var isReset: Bool = false

    init() {
        container = CKContainer.default()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
        user = User(container: container)
        user.loggedInToICloud { accountStatus, error in
            let enabled = accountStatus == .available || accountStatus == .couldNotDetermine
            if enabled {
                user.userID { userRecord, error in
                    if error == nil {
                        self.loggedIn = true
                        self.refresh()
                        Analytics.logFunction(function: "cloudkit",
                                              parameters: ["action": "login" as AnyObject,
                                                           "user": userRecord?.recordName as AnyObject])

                    }
                }
            }
        }

    }

    private func queryAudioPlays(finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        let predicate = NSPredicate(value: true)
        let queryAudioPlay = CKQuery(recordType: "AudioPlay", predicate: predicate)
        privateDB.perform(queryAudioPlay, inZoneWith: nil) { results, error in

            guard error == nil else {
                DispatchQueue.main.async {
                    let jferror = JFError(code: Int(errno),
                                          desc: "Error",
                                          reason: "Cannot download info",
                                          suggestion: "Please check your internet connection",
                                          underError: error as NSError?)
                    finishClosure?(jferror)
                }
                return
            }

            if let results = results {
                RestApi.instance.context?.performAndWait {
                    for record in results {
                        print(record)
                        if self.isReset {
                            self.remove(withRecordID: record.recordID)
                        }
                        else {
                            _ = AudioPlay.create(record: record)
                        }
                    }
                }
            }

            DispatchQueue.main.async {
                finishClosure?(nil)
            }
        }
    }

    private func queryBookmarks(finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        let predicate = NSPredicate(value: true)
        let queryBookmark = CKQuery(recordType: "Bookmark", predicate: predicate)
        privateDB.perform(queryBookmark, inZoneWith: nil) { results, error in

            guard error == nil else {
                DispatchQueue.main.async {
                    let jferror = JFError(code: Int(errno),
                                          desc: "Error",
                                          reason: "Cannot download info",
                                          suggestion: "Please check your internet connection",
                                          underError: error as NSError?)
                    finishClosure?(jferror)
                }
                return
            }

            
            if let results = results {
                RestApi.instance.context?.performAndWait {
                    for record in results {
                        print(record)
                        if self.isReset {
                            self.remove(withRecordID: record.recordID)
                        }
                        else {
                            _ = Bookmark.create(record: record)
                        }
                    }
                }
            }

            self.queryAudioPlays(finishClosure: finishClosure)
        }
    }

    func refresh(finishClosure: ((_ error: JFError?) -> Void)? = nil) {

        if loggedIn == false {
            DispatchQueue.main.async {
                finishClosure?(nil)
            }
            return
        }
        queryBookmarks(finishClosure: finishClosure)
    }
    
    func remove(withRecordID recordID: CKRecord.ID, finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        privateDB.delete(withRecordID: recordID) { (_, error) in
            guard error == nil else {
                DispatchQueue.main.async {
                    let jferror = JFError(code: Int(errno),
                                          desc: "Error",
                                          reason: "Cannot remove record",
                                          suggestion: "Please check your internet connection",
                                          underError: error as NSError?)
                    finishClosure?(jferror)
                }
                return
            }
            
            DispatchQueue.main.async {
                finishClosure?(nil)
            }
        }

    }

    func remove(bookmark: Bookmark?, finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        if loggedIn == false {
            finishClosure?(nil)
            return
        }

        guard let bookmark = bookmark,
            let recordName = bookmark.recordID else {
                finishClosure?(nil)
                return
        }

        let recordId = CKRecord.ID.init(recordName: recordName)
        remove(withRecordID: recordId) { (error) in
            bookmark.error = error?.message()
            finishClosure?(error)
        }
    }

    func save(bookmark: Bookmark?, finishClosure: ((_ error: JFError?) -> Void)? = nil) {

        if loggedIn == false {
            finishClosure?(nil)
            return
        }
        remove(bookmark: bookmark) { (error) in
            if error != nil {
                bookmark?.error = error?.message()
                return
            }

            guard let bookmark = bookmark else { return }
            
            let ckBookmark = CKRecord(recordType: "Bookmark")
            if let detail = bookmark.detail as CKRecordValue? {
                ckBookmark.setObject(detail, forKey: "detail")
            }
            if let id = bookmark.id as CKRecordValue? {
                ckBookmark.setObject(id, forKey: "id")
            }
            if let placeholder = bookmark.placeholder as CKRecordValue? {
                ckBookmark.setObject(placeholder, forKey: "placeholder")
            }
            ckBookmark.setObject(bookmark.section as CKRecordValue?, forKey: "section")
            ckBookmark.setObject(bookmark.subTitle as CKRecordValue?, forKey: "subTitle")
            ckBookmark.setObject(bookmark.thumbnailUrl as CKRecordValue?, forKey: "thumbnailUrl")
            ckBookmark.setObject(bookmark.title as CKRecordValue?, forKey: "title")
            ckBookmark.setObject(bookmark.url as CKRecordValue?, forKey: "url")
            ckBookmark.setObject(bookmark.descript as CKRecordValue?, forKey: "descript")
            
            self.privateDB.save(ckBookmark, completionHandler: { record, error in
                
                DispatchQueue.main.async {
                    
                    guard error == nil else {
                        
                        let jferror = JFError(code: Int(errno),
                                              desc: "Error",
                                              reason: "Cannot save Bookmark",
                                              suggestion: "Please check your internet connection",
                                              underError: error as NSError?)
                        bookmark.error = jferror.message()
                        finishClosure?(jferror)
                        return
                    }
                    bookmark.recordID = record?.recordID.recordName
                    finishClosure?(nil)
                }
                
            })

        }
    }

    func remove(audioPlay: AudioPlay?, finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        if loggedIn == false {
            finishClosure?(nil)
            return
        }

        guard let audioPlay = audioPlay,
            let recordName = audioPlay.recordID else {
                finishClosure?(nil)
                return
        }


        let recordId = CKRecord.ID.init(recordName: recordName)
        remove(withRecordID: recordId) { (error) in
            audioPlay.error = error?.message()
            finishClosure?(error)
        }
    }

    func save(audioPlay: AudioPlay?, finishClosure: ((_ error: JFError?) -> Void)? = nil) {

        if loggedIn == false {
            finishClosure?(nil)
            return
        }
        
        remove(audioPlay: audioPlay) { (error) in
            if error != nil {
                audioPlay?.error = error?.message()
                return
            }
            guard let audioPlay = audioPlay else { return }
            
            let ckAudioPlay = CKRecord(recordType: "AudioPlay")
            if let detail = audioPlay.detail as CKRecordValue? {
                ckAudioPlay.setObject(detail, forKey: "detail")
            }
            if let id = audioPlay.id as CKRecordValue? {
                ckAudioPlay.setObject(id, forKey: "id")
            }
            if let placeholder = audioPlay.placeholder as CKRecordValue? {
                ckAudioPlay.setObject(placeholder, forKey: "placeholder")
            }
            ckAudioPlay.setObject(audioPlay.section as CKRecordValue?, forKey: "section")
            ckAudioPlay.setObject(audioPlay.subTitle as CKRecordValue?, forKey: "subTitle")
            ckAudioPlay.setObject(audioPlay.thumbnailUrl as CKRecordValue?, forKey: "thumbnailUrl")
            ckAudioPlay.setObject(audioPlay.title as CKRecordValue?, forKey: "title")
            ckAudioPlay.setObject(audioPlay.urlString as CKRecordValue?, forKey: "url")
            ckAudioPlay.setObject(audioPlay.descript as CKRecordValue?, forKey: "descript")
            
            self.privateDB.save(ckAudioPlay, completionHandler: { record, error in

                DispatchQueue.main.async {
                    
                    guard error == nil else {
                        
                        let jferror = JFError(code: Int(errno),
                                              desc: "Error",
                                              reason: "Cannot save Audioplay",
                                              suggestion: "Please check your internet connection",
                                              underError: error as NSError?)
                        audioPlay.error = jferror.message()
                        finishClosure?(jferror)
                        return
                    }
                    audioPlay.recordID = record?.recordID.recordName
                    finishClosure?(nil)
                }
                
            })

        }

    }

    func clean(finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        isReset = true
        if loggedIn == false {
            return
        }
        
        refresh { (error) in
            self.isReset = false
            finishClosure?(error)
        }
        
    }
}
