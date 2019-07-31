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
            iconView.text = model?.iconText()
            iconView.textColor = model?.iconColor
            detailView.text = model?.title
            detailView.textColor = model?.textColor
            detailView.font = model?.font
            selectionStyle = model?.selectionStyle ?? .none
            accessoryType = model?.accessoryType ?? .none
//            if let isBookmarked = model?.isBookmarked {
//                bookmarkButton.isHidden = false
//                bookmarkButton.isHighlighted = isBookmarked
//            }
//            else {
                bookmarkButton.isHidden = true
//            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconView.text = "\(Commons.symbols.showAwesome(icon: .ban))"
        detailView.text = "No Info"
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
