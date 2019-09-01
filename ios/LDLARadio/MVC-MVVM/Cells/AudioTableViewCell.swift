//
//  AudioTableViewCell.swift
//  LDLARadio
//
//  Created by Javier Fuchs on 1/6/17.
//  Copyright © 2017 Mobile Patagonia. All rights reserved.
//

import UIKit
import AlamofireImage
import JFCore
import AVKit
import MediaPlayer

class AudioTableViewCell: UITableViewCell {
    // MARK: Properties

    static let reuseIdentifier: String = "AudioTableViewCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var downloadStateLabel: UILabel!
    @IBOutlet weak var downloadProgressView: UIProgressView!
    @IBOutlet weak var bookmarkButton: UIButton!

    weak var delegate: AudioTableViewCellDelegate?
    fileprivate let formatter = DateComponentsFormatter()
    let gradientBg = CAGradientLayer()
    let gradientPlayBg = CAGradientLayer()

    var model: AudioViewModel? = nil {
        didSet {
            let labels = [downloadStateLabel, subtitleLabel, titleLabel]
            let texts = [model?.detail, model?.subTitle, model?.title]
            for i in 0..<3 {
                if let text = texts[i]?.text, text.count > 0 {
                    labels[i]?.isHidden = false
                    labels[i]?.text = text
                    labels[i]?.textColor = texts[i]?.color
                    labels[i]?.font = texts[i]?.font
                } else {
                    labels[i]?.isHidden = true
                    if i == 0 {
                        titleLabel.numberOfLines = 3
                    } else if i == 1 {
                        titleLabel.numberOfLines += 2
                    }
                }
            }

            if let thumbnailUrl = model?.thumbnailUrl {
                thumbnailView.af_setImage(withURL: thumbnailUrl, placeholderImage: model?.placeholderImage) { (_) in
                    self.model?.image = self.thumbnailView.image
                }
            }
            bookmarkButton.isHighlighted = model?.isBookmarked ?? false

            if model?.isPlaying ?? false {
                gradientPlayBg.isHidden = false
            } else {
                gradientPlayBg.isHidden = true
            }
            selectionStyle = .none
            // show thumbnail, and hide logo
            thumbnailView.isHidden = false

            setNeedsLayout()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        gradientBg.startPoint = CGPoint.init(x: 0, y: 1)
        gradientBg.endPoint = CGPoint.init(x: 1, y: 1)
        gradientBg.colors = [UIColor.white.cgColor, UIColor.lightGray.cgColor]
        gradientBg.frame = contentView.bounds
        contentView.layer.insertSublayer(gradientBg, at: 0)
        gradientBg.isHidden = false

        gradientPlayBg.startPoint = CGPoint.init(x: 0, y: 1)
        gradientPlayBg.endPoint = CGPoint.init(x: 1, y: 1)
        gradientPlayBg.colors = [UIColor.turquoise.cgColor, UIColor.aqua.cgColor]
        gradientPlayBg.frame = contentView.bounds
        gradientPlayBg.isHidden = false
        contentView.layer.insertSublayer(gradientPlayBg, at: 1)

        formatter.allowedUnits = [.second, .minute, .hour]
        formatter.zeroFormattingBehavior = .pad
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        for label in [ downloadStateLabel, subtitleLabel, titleLabel] {
            label?.text = ""
            label?.isHidden = false
            label?.numberOfLines = 1
        }

        downloadProgressView.isHidden = true
        bookmarkButton.isHighlighted = false
    }

    @IBAction func bookmarkAction(_ sender: UIButton?) {
        bookmarkButton.isHighlighted = !bookmarkButton.isHighlighted
        delegate?.audioTableViewCell(self, bookmarkDidChange: bookmarkButton.isHighlighted)
    }
}

protocol AudioTableViewCellDelegate: class {

    func audioTableViewCell(_ cell: AudioTableViewCell, downloadStateDidChange newState: Stream.DownloadState)
    func audioTableViewCell(_ cell: AudioTableViewCell, bookmarkDidChange newState: Bool)
    
}

