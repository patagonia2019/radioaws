//
//  LaunchViewController.swift
//  LDLARadio
//
//  Created by fox on 03/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import UIKit
import JFCore

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
        versionLabel.text = "Copyright © \(Date().year() ?? "2019") Mobile Patagonia. All rights reserved - v\(bundleShortVersion).b\(bundleVersion)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let info = Bundle.main.infoDictionary,
            let bundleShortVersion = info["CFBundleShortVersionString"] as? String,
            let bundleVersion = info["CFBundleVersion"] as? String
            else {
                fatalError()
        }

        Analytics.logFunction(function: "launch",
                              parameters: ["version": "v\(bundleShortVersion).b\(bundleVersion)" as AnyObject])
        
    }
   
    @IBAction func shareAction(_ sender: Any) {
        share(indexPath: nil)
    }

}
