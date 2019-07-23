//
//  RNAViewController.swift
//  LDLARadio
//
//  Created by fox on 23/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Foundation
import UIKit

class RNAViewController: BaseAudioViewController {
    // MARK: Properties
    
    var rnaController = RNAController()
    override var controller: BaseController {
        get {
            return rnaController
        }
        set {
            if newValue is RNAController {
                rnaController = newValue as! RNAController
            } else {
                print("incorrect controller type")
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }

}

