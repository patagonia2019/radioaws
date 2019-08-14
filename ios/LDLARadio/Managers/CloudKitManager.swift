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

    init() {
        container = CKContainer.default()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
        user = User(container: container)
        user.loggedInToICloud() { accountStatus, error in
            let enabled = accountStatus == .available || accountStatus == .couldNotDetermine
            if enabled {
                user.userID() { userRecord, error in
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
    
    func refresh(finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        
        if loggedIn == false {
            DispatchQueue.main.async {
                finishClosure?(nil)
            }
            return
        }
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Bookmark", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil) { results, error in
            
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
                        _ = Bookmark.create(record: record)
                    }
                }
            }
            
            DispatchQueue.main.async {
                finishClosure?(nil)
            }
        }
    }
    
    func remove(bookmark: Bookmark?, finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        if loggedIn == false {
            return
        }
        
        guard let bookmark = bookmark,
            let recordName = bookmark.recordID else { return }
        
        let recordId = CKRecord.ID.init(recordName: recordName)
        privateDB.delete(withRecordID: recordId) { (id, error) in
            guard error == nil else {
                DispatchQueue.main.async {
                    let jferror = JFError(code: Int(errno),
                                      desc: "Error",
                                      reason: "Cannot remove bookmark",
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
    
    func save(bookmark: Bookmark?, finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        
        if loggedIn == false {
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

        
        privateDB.save(ckBookmark, completionHandler: { record, error in
            
            DispatchQueue.main.async {
                
                guard error == nil else {
                    
                    let jferror = JFError(code: Int(errno),
                                          desc: "Error",
                                          reason: "Cannot save Bookmark",
                                          suggestion: "Please check your internet connection",
                                          underError: error as NSError?)
                    finishClosure?(jferror)
                    return
                }
                bookmark.recordID = record?.recordID.recordName
                finishClosure?(nil)
            }

        })
    }

}
