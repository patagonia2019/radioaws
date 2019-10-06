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
    var working = false

    init() {
        container = CKContainer.default()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
        user = User(container: container)
        if working == true {
            return
        }
        working = true
        user.loggedInToICloud { accountStatus, error in
            working = false
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
        if working == true {
            return
        }
        working = true

        privateDB.perform(queryAudioPlay, inZoneWith: nil) { results, error in

            if let results = results {
                self.audios.append(contentsOf: results)
                RestApi.instance.context?.performAndWait {
                    for record in results {
                        Log.debug("record = %@", record.recordID)
                        if self.isReset {
                            self.remove(withRecordID: record.recordID)
                        } else {
                            let audio = Audio.create(record: record)
                            audio?.cloudSynced = true
                        }
                    }
                    CoreDataManager.instance.save()
                    self.working = false
                }
            }

            DispatchQueue.main.async {
                var jferror: JFError?
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
        if working == true {
            return
        }
        working = true

        remove(withRecordID: recordId) { (error) in
            audio.errorTitle = error?.title()
            audio.errorMessage = error?.message()
            self.working = false
            finishClosure?(error)
        }
    }

    func convert(audio: Audio?) {

        if audio?.cloudSynced == true {
            return
        }

        if loggedIn == false {
            return
        }

        guard let audio = audio else {
            return
        }

        var ckAudio = audios.first { (record) -> Bool in
            record["urlString"] == audio.urlString
        }

        if ckAudio == nil {
            ckAudio = CKRecord(recordType: "Audio")
            if let ckAudio = ckAudio {
                audios.append(ckAudio)
            }
        }

        ckAudio?.setObject(audio.currentTime as CKRecordValue?, forKey: "currentTime")
        ckAudio?.setObject(audio.descript as CKRecordValue?, forKey: "descript")
        ckAudio?.setObject(audio.detail as CKRecordValue?, forKey: "detail")
        if let downloadFiles = audio.downloadFiles, !downloadFiles.isEmpty {
            ckAudio?.setObject(downloadFiles as CKRecordValue?, forKey: "downloadFiles")
        }
        ckAudio?.setObject(audio.hasDuration as CKRecordValue?, forKey: "hasDuration")
        ckAudio?.setObject(audio.id as CKRecordValue?, forKey: "id")
        ckAudio?.setObject(audio.isBookmark as CKRecordValue?, forKey: "isBookmark")
        ckAudio?.setObject(audio.isDownloading as CKRecordValue?, forKey: "isDownloading")
        ckAudio?.setObject(audio.isPlaying as CKRecordValue?, forKey: "isPlaying")
        ckAudio?.setObject(audio.placeholder as CKRecordValue?, forKey: "placeholder")
        ckAudio?.setObject(audio.section as CKRecordValue?, forKey: "section")
        ckAudio?.setObject(audio.subTitle as CKRecordValue?, forKey: "subTitle")
        ckAudio?.setObject(audio.thumbnailUrl as CKRecordValue?, forKey: "thumbnailUrl")
        ckAudio?.setObject(audio.title as CKRecordValue?, forKey: "title")
        ckAudio?.setObject(audio.urlString as CKRecordValue?, forKey: "urlString")

    }

    @objc func sync(force: Bool = false) {
        if let unsyncs = Audio.unsyncs() {
            for audio in unsyncs {
                convert(audio: audio)
            }
        }
        modifyRecords(records: audios, force: force)
    }

    private func modifyRecords(records: [CKRecord]?, force: Bool = false) {
        if working == true {
            return
        }
        working = true

        guard let lastMin = Calendar.current.date(byAdding: Calendar.Component.minute, value: -5, to: Date()) else {
            working = false
            return
        }

        // force, not check modification Date
        guard let records = force ? records : records?.filter({ (record) -> Bool in
            let modificationDate = record.modificationDate
            if modificationDate == nil {
                return true
            }

            if  let modificationDate = modificationDate,
                modificationDate < lastMin {
                return true
            }

            return false
        }) else {
            working = false
            return
        }

        if records.isEmpty {
            working = false
            return
        }

        let modifyRecords = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        modifyRecords.savePolicy = CKModifyRecordsOperation.RecordSavePolicy.allKeys
        modifyRecords.qualityOfService = QualityOfService.userInitiated
        modifyRecords.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
            RestApi.instance.context?.performAndWait {
                if let savedRecords = savedRecords {
                    Log.debug("savedRecords: %@", savedRecords.debugDescription)
                    for saveRecord in savedRecords {
                        if let audio = Audio.search(byUrl: saveRecord["urlString"]) {
                            audio.cloudSynced = true
                            audio.modificationDate = saveRecord.modificationDate
                        }
                    }
                }
                if let error = error {
                    Log.error("CloudKit error: %@", error.localizedDescription)
                }
                self.working = false
                CoreDataManager.instance.save()
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
