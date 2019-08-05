//
//  CatalogTableViewCell.swift
//  LDLARadio
//
//  Created by fox on 13/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import UIKit

class CatalogTableViewCell : UITableViewCell {
    static let reuseIdentifier: String = "CatalogTableViewCell"

    @IBOutlet weak var iconView: UILabel!
    @IBOutlet weak var detailView: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!

    var actionBookmarkBlock: ((_ catalogViewModel: CatalogViewModel?, _ isBookmarking: Bool) -> ())? = nil

    var model : CatalogViewModel? = nil {
        didSet {
            if let model = model {
                iconView.text = model.iconText()
                iconView.textColor = model.iconColor
                detailView.text = model.title.text
                detailView.textColor = model.title.color
                detailView.font = model.title.font
                selectionStyle = model.selectionStyle
                accessoryType = model.accessoryType
            }
            bookmarkButton.isHidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconView.text = "\(Commons.symbols.showAwesome(icon: .battery_empty))"
        iconView.textColor = .red
        detailView.text = "No Info"
        detailView.textColor = .red
        selectionStyle = .none
        accessoryType = .none
        bookmarkButton.isHidden = true
        bookmarkButton.isHighlighted = false
    }
    
    @IBAction func bookmarkAction(_ sender: UIButton?) {
        
        if sender == bookmarkButton {
            bookmarkButton.isHighlighted = !bookmarkButton.isHighlighted
            actionBookmarkBlock?(model, bookmarkButton.isHighlighted)
        }
        else {
            fatalError()
        }
    }
}
