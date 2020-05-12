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

    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    override func prepareForReuse() {
        super.prepareForReuse()
        clear()
    }

    func tryAgain() {
        titleView.text = "Please try again with another search term."
        titleView.textColor = UIColor.nickel
        spinner.stopAnimating()
    }

    func clear() {
        titleView.text = "Tap to load more..."
        titleView.textColor = UIColor.lavender
        spinner.stopAnimating()
    }

    func start() {
        titleView.text = "Loading..."
        titleView.textColor = UIColor.spring
        spinner.startAnimating()
    }

}
