//
//  HeaderTableView.swift
//  LDLARadio
//
//  Created by fox on 29/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class HeaderTableView : UITableViewHeaderFooterView {
    static let reuseIdentifier: String = "HeaderTableView"

    @IBOutlet weak var expandButton: UIButton?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var bookmarkButton: UIButton?
    
    var actionExpandBlock: ((_ catalogViewModel: CatalogViewModel?, _ isExpanding: Bool) -> ())? = nil
    var actionBookmarkBlock: ((_ catalogViewModel: CatalogViewModel?, _ isBookmarking: Bool) -> ())? = nil
    
    var model : CatalogViewModel? {
        didSet {
            titleLabel?.text = model?.title.text
            if let model = model {
                if let isExpanded = model.isExpanded {
                    expandButton?.isHidden = false
                    expandButton?.isHighlighted = isExpanded
                }
                else {
                    expandButton?.isHidden = false
                }
                if let isBookmarked = model.isBookmarked {
                    bookmarkButton?.isHidden = false
                    bookmarkButton?.isHighlighted = isBookmarked
                }
                else {
                    bookmarkButton?.isHidden = true
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        expandButton?.isHidden = true
        expandButton?.isHighlighted = false
        bookmarkButton?.isHidden = true
        bookmarkButton?.isHighlighted = false
    }
    
    static func setup(tableView: UITableView?) {
        let headerNib = UINib.init(nibName: nibName(), bundle: Bundle.main)
        tableView?.register(headerNib, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
    }

    class func nibName() -> String {
        return "Main"
    }

    @IBAction func expandAction(_ sender: Any) {
        if let expandButton = expandButton {
            expandButton.isHighlighted = !expandButton.isHighlighted
            actionExpandBlock?(model, expandButton.isHighlighted)
        }
    }

    @IBAction func bookmarkAction(_ sender: UIButton?) {
        
        if let bookmarkButton = bookmarkButton  {
            bookmarkButton.isHighlighted = !bookmarkButton.isHighlighted
            actionBookmarkBlock?(model, bookmarkButton.isHighlighted)
        }
        else {
            fatalError()
        }
    }

}




