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
    
    var catalogController = RTCatalogController()
    override var controller: BaseController {
        get {
            return catalogController
        }
        set {
            if newValue is RTCatalogController {
                catalogController = newValue as! RTCatalogController
            } else {
                print("incorrect controller type")
            }
        }
    }
}

