//
//  LoadTableViewCell.swift
//  LDLARadio
//
//  Created by fox on 14/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import UIKit

class LoadTableViewCell: UITableViewCell {
    static let reuseIdentifier: String = "LoadTableViewCell"

    @IBOutlet weak var iconView: UILabel!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    override func prepareForReuse() {

        titleView.text = "Tap to load more..."
        titleView.textColor = UIColor.lavender
        spinner.stopAnimating()
    }

    func start() {
        titleView.text = "Loading..."
        titleView.textColor = UIColor.blueberry
        spinner.startAnimating()
    }

}
