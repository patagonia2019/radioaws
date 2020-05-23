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
    
    private func attributedText(quote: String, color: UIColor) -> NSAttributedString {
        let attributedQuote = NSMutableAttributedString(string: quote)
        attributedQuote.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: quote.count))
        return attributedQuote
    }

    func tryAgain() {
        titleView.attributedText = attributedText(quote: "Please try again with another search term.", color: .nickel)
        spinner.stopAnimating()
    }

    func clear() {
        titleView.attributedText = attributedText(quote: "Tap to load more Records...", color: .lavender)
        spinner.stopAnimating()
    }

    func start() {
        titleView.attributedText = attributedText(quote: "Loading...", color: .blueberry)
        spinner.startAnimating()
    }

}
