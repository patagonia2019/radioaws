//
//  BookmarkViewController.swift
//  LDLARadio
//
//  Created by fox on 24/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import UIKit

class BookmarkViewController: BaseAudioViewController {
 
    // MARK: Properties
    var bookmarkController = BookmarkController()
    override var controller: BaseController {
        get {
            return bookmarkController
        }
        set {
            if newValue is BookmarkController {
                bookmarkController = newValue as! BookmarkController
            } else {
                print("incorrect controller type")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let center = NotificationCenter.default
        center.addObserver(forName: BookmarkController.didRefreshNotification, object: self, queue: OperationQueue.main) { _ in
            self.refresh()
        }
    
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
}

