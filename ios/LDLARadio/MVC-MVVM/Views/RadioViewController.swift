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
    
    var audioController = AudioController()
    override var controller: BaseController {
        get {
            return audioController
        }
        set {
            if newValue is AudioController {
                audioController = newValue as! AudioController
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

