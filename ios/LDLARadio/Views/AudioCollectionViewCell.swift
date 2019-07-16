//
//  AudioCollectionViewCell.swift
//  LDLARadio
//
//  Created by fox on 15/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage

@IBDesignable
class AudioCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    
    var model : AudioViewModel? = nil {
        didSet {
            detailLabel.text = model?.detail
            detailLabel.textColor = model?.detailColor
            detailLabel.font = model?.detailFont
            subtitleLabel.text = model?.subTitle
            subtitleLabel.textColor = model?.subTitleColor
            subtitleLabel.font = model?.subTitleFont
            titleLabel.text = model?.title
            titleLabel.textColor = model?.titleColor
            titleLabel.font = model?.titleFont
            if let thumbnailUrl = model?.thumbnailUrl {
                iconView.af_setImage(withURL: thumbnailUrl)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        detailLabel.text = ""
        subtitleLabel.text = ""
        titleLabel.text = ""
        iconView.image = nil
    }

}
