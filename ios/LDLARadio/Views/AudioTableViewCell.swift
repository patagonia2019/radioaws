//
//  AudioTableViewCell.swift
//  LDLARadio
//
//  Created by Javier Fuchs on 1/6/17.
//  Copyright © 2017 Mobile Patagonia. All rights reserved.
//

import UIKit
import AlamofireImage

class AudioTableViewCell: UITableViewCell {
    // MARK: Properties
    
    static let reuseIdentifier = "AudioTableViewCellIdentifier"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var downloadStateLabel: UILabel!
    @IBOutlet weak var downloadProgressView: UIProgressView!
    
    weak var delegate: AssetListTableViewCellDelegate?
    
    var model : AudioViewModel? = nil {
        didSet {
            downloadStateLabel.text = model?.detail
            downloadStateLabel.textColor = model?.detailColor
            downloadStateLabel.font = model?.detailFont
            subtitleLabel.text = model?.subTitle
            subtitleLabel.textColor = model?.subTitleColor
            subtitleLabel.font = model?.subTitleFont
            titleLabel.text = model?.title
            titleLabel.textColor = model?.titleColor
            titleLabel.font = model?.titleFont
            if let thumbnailUrl = model?.thumbnailUrl {
                logoView.af_setImage(withURL: thumbnailUrl)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        subtitleLabel.text = ""
        titleLabel.text = ""
        logoView.image = nil
        downloadStateLabel.text = ""
        downloadProgressView.isHidden = true
    }    
}

protocol AssetListTableViewCellDelegate: class {
    
    func assetListTableViewCell(_ cell: AudioTableViewCell, downloadStateDidChange newState: Stream.DownloadState)
}
