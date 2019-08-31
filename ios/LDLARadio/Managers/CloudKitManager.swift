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
    var audios = [CKRecord]()

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
        let queryAudioPlay = CKQuery(recordType: "Audio", predicate: predicate)
        privateDB.perform(queryAudioPlay, inZoneWith: nil) { results, error in

            if let results = results {
                self.audios.append(contentsOf: results)
                RestApi.instance.context?.performAndWait {
                    for record in results {
                        print(record)
                        if self.isReset {
                            self.remove(withRecordID: record.recordID)
                        }
                        else {
                            _ = Audio.create(record: record)
                        }
                    }
                }
            }

            DispatchQueue.main.async {
                var jferror : JFError? = nil
                if let error = error {
                    jferror = JFError(code: Int(errno),
                                      desc: "Error",
                                      reason: "Cannot sync cloud kit",
                                      suggestion: "Please check your internet connection",
                                      underError: error as NSError?)
                }
                finishClosure?(jferror)
            }
        }
    }

    func refresh(finishClosure: ((_ error: JFError?) -> Void)? = nil) {

        if loggedIn == false {
            DispatchQueue.main.async {
                finishClosure?(nil)
            }
            return
        }
        queryAudioPlays(finishClosure: finishClosure)
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

    func remove(audio: Audio?, finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        if loggedIn == false {
            finishClosure?(nil)
            return
        }

        guard let audio = audio,
            let recordName = audio.recordID else {
                finishClosure?(nil)
                return
        }

        let recordId = CKRecord.ID.init(recordName: recordName)
        remove(withRecordID: recordId) { (error) in
            audio.error = error?.message()
            finishClosure?(error)
        }
    }

    func save(audio: Audio?, finishClosure: ((_ error: JFError?) -> Void)? = nil) {

        audio?.cloudSynced = false

        if loggedIn == false {
            finishClosure?(nil)
            return
        }
        
        guard let audio = audio else {
            finishClosure?(nil)
            return
        }

        var ckAudio = audios.first { (record) -> Bool in
            return record.recordID.recordName == audio.recordID
        }
        
        if ckAudio == nil {
            ckAudio = CKRecord(recordType: "Audio")
        }
        
        ckAudio?.setObject(audio.currentTime as CKRecordValue?, forKey: "currentTime")
        ckAudio?.setObject(audio.descript as CKRecordValue?, forKey: "descript")
        ckAudio?.setObject(audio.detail as CKRecordValue?, forKey: "detail")
        ckAudio?.setObject(audio.downloadFiles as CKRecordValue?, forKey: "downloadFiles")
        ckAudio?.setObject(audio.hasDuration as CKRecordValue?, forKey: "hasDuration")
        ckAudio?.setObject(audio.id as CKRecordValue?, forKey: "id")
        ckAudio?.setObject(audio.isBookmark as CKRecordValue?, forKey: "isBookmark")
        ckAudio?.setObject(audio.isDownloading as CKRecordValue?, forKey: "isDownloading")
        ckAudio?.setObject(audio.isPlaying as CKRecordValue?, forKey: "isPlaying")
        ckAudio?.setObject(audio.placeholder as CKRecordValue?, forKey: "placeholder")
        ckAudio?.setObject(audio.recordID as CKRecordValue?, forKey: "recordID")
        ckAudio?.setObject(audio.section as CKRecordValue?, forKey: "section")
        ckAudio?.setObject(audio.subTitle as CKRecordValue?, forKey: "subTitle")
        ckAudio?.setObject(audio.thumbnailUrl as CKRecordValue?, forKey: "thumbnailUrl")
        ckAudio?.setObject(audio.title as CKRecordValue?, forKey: "title")
        ckAudio?.setObject(audio.urlString as CKRecordValue?, forKey: "urlString")

        if ckAudio?.recordID.recordName == nil {
            guard let cloudKitAudio = ckAudio else {
                finishClosure?(nil)
                return
            }
            self.privateDB.save(cloudKitAudio, completionHandler: { record, error in
                
                DispatchQueue.main.async {
                    
                    guard error == nil else {
                        
                        let jferror = JFError(code: Int(errno),
                                              desc: "Error",
                                              reason: "Cannot save Audio",
                                              suggestion: "Please check your internet connection",
                                              underError: error as NSError?)
                        audio.error = jferror.message()
                        finishClosure?(jferror)
                        return
                    }
                    audio.cloudSynced = true
                    audio.recordID = record?.recordID.recordName
                    finishClosure?(nil)
                }
            })
        }
    }

    func sync() {
        if let dbAudios = Audio.all() {
            for audio in dbAudios {
                save(audio: audio)
            }
        }
        modifyRecords(records: audios)
    }

    private func modifyRecords(records: [CKRecord]?) {
        guard let records = records else {
            return
        }
        let modifyRecords = CKModifyRecordsOperation(recordsToSave:records, recordIDsToDelete: nil)
        modifyRecords.savePolicy = CKModifyRecordsOperation.RecordSavePolicy.allKeys
        modifyRecords.qualityOfService = QualityOfService.userInitiated
        modifyRecords.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
            if let error = error {
                print(error)
            }
        }
        privateDB.add(modifyRecords)

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
