//
//  CatalogTableViewCell.swift
//  LDLARadio
//
//  Created by fox on 13/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Foundation
import UIKit

class CatalogTableViewCell : UITableViewCell {
    
    @IBOutlet weak var iconView: UILabel!
    @IBOutlet weak var detailView: UILabel!
    
    var model : CatalogViewModel? = nil {
        didSet {
            iconView.text = model?.iconText()
            iconView.textColor = model?.color
            detailView.text = model?.detail
            detailView.textColor = model?.color
            detailView.font = model?.font
            selectionStyle = model?.selectionStyle ?? .none
            accessoryType = model?.accessoryType ?? .none
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconView.text = ""
        detailView.text = ""
    }
    
}
