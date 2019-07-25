//
//  RadioViewController.swift
//  LDLARadio
//
//  Created by Javier Fuchs on 1/6/17.
//  Copyright © 2017 Mobile Patagonia. All rights reserved.
//

import UIKit

class RadioViewController: BaseAudioViewController {
    // MARK: Properties
    
    var radioController = RadioController()
    override var controller: BaseController {
        get {
            return radioController
        }
        set {
            if newValue is RadioController {
                radioController = newValue as! RadioController
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

