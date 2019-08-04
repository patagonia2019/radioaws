//
//  LaunchViewController.swift
//  LDLARadio
//
//  Created by fox on 03/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import UIKit

class LaunchViewController : UIViewController {
    
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let info = Bundle.main.infoDictionary,
            let bundleShortVersion = info["CFBundleShortVersionString"] as? String,
            let bundleVersion = info["CFBundleVersion"] as? String
            else {
                fatalError()
        }
        versionLabel.text = "Los Locos de la Azotea v\(bundleShortVersion).b\(bundleVersion). Copyright © \(Date().year() ?? "2019") Mobile Patagonia. All rights reserved."
    }
}
