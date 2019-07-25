//
//  RadioTimeViewController.swift
//  LDLARadio
//
//  Created by fox on 22/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import UIKit

class RadioTimeViewController: BaseAudioViewController {
    // MARK: Properties
    
    var catalogController = RadioTimeController()
    override var controller: BaseController {
        get {
            return catalogController
        }
        set {
            if newValue is RadioTimeController {
                catalogController = newValue as! RadioTimeController
            } else {
                print("incorrect controller type")
            }
        }
    }
}

