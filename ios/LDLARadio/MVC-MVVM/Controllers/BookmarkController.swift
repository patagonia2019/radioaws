//
//  BookmarkController.swift
//  LDLARadio
//
//  Created by fox on 24/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Foundation
import JFCore

class BookmarkController: BaseController {
    
    /// Notification for when bookmark has changed.
    static let didRefreshNotification = NSNotification.Name(rawValue: "BookmarkController.didRefreshNotification")
        
    var models = [AudioViewModel]()
    
    override var useRefresh : Bool {
        return false
    }

    override init() {
    }
    
    override func prompt() -> String {
        return "Bookmarks"
    }

    override func numberOfRows(inSection section: Int) -> Int {
        return models.count
    }
    
    override func model(forSection section: Int, row: Int) -> Any? {
        if row < models.count {
            return models[row]
        }
        return nil
    }
    
    override func heightForRow(at section: Int, row: Int) -> CGFloat {
        return CGFloat(AudioViewModel.height())
    }
    
    override func privateRefresh(isClean: Bool = false,
                                 prompt: String,
                                 startClosure: (() -> Void)? = nil,
                                 finishClosure: ((_ error: Error?) -> Void)? = nil) {
        
        finishBlock = finishClosure
        
        startClosure?()
        
        RestApi.instance.context?.performAndWait {
            let all = Bookmark.all()
            models = all?.map({ AudioViewModel(bookmark: $0) }) ?? [AudioViewModel]()
            if let bDate = Bookmark.lastUpdated(),
                let lastDate = lastUpdated {
                if bDate > lastDate {
                    self.lastUpdated = bDate
                }
            }
            else {
                self.lastUpdated = Date()
            }
            finishClosure?(nil)
        }
    }

}
