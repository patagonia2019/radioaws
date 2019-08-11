//
//  User.swift
//  LDLARadio
//
//  Created by fox on 10/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import CloudKit

class User {
    
    // MARK: - Properties
    let container: CKContainer
    var userRecordID: CKRecord.ID!
    var contacts: [AnyObject] = []
    
    // MARK: - Initializers
    init (container: CKContainer) {
        self.container = container;
    }
    
    func loggedInToICloud(_ completion: (_ accountStatus: CKAccountStatus, _ error: NSError?) -> ()) {
        // Capability not yet implemented.
        completion(.couldNotDetermine, nil)
    }
    
    func userID(_ completion: @escaping (_ userRecordID: CKRecord.ID?, _ error: NSError?)->()) {
        
        guard userRecordID != nil else {
            container.fetchUserRecordID() { recordID, error in
                
                if recordID != nil {
                    self.userRecordID = recordID
                }
                completion(recordID, error as NSError?)
            }
            return
        }
        completion(userRecordID, nil)
    }
    
}
