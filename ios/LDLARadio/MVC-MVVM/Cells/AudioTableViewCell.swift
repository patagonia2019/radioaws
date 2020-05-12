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
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!

    weak var delegate: AudioTableViewCellDelegate?
    let gradientBg = CAGradientLayer()
    let gradientPlayBg = CAGradientLayer()

    var model: AudioViewModel? = nil {
        didSet {
            guard let model = model else { return }
            let labels = [detailLabel, subtitleLabel, titleLabel]
            let texts = [model.detail, model.subTitle, model.title]
            for i in 0..<texts.count {
                let text = texts[i].text
                let label = labels[i]
                if !texts[i].isEmpty {
                    label?.isHidden = false
                    label?.text = text
                    label?.textColor = texts[i].color
                    label?.font = texts[i].font
                } else {
                    label?.text = nil
                }
            }

            thumbnailView.image = model.placeholderImage
            if let thumbnailUrl = model.thumbnailUrl {
                thumbnailView.af_setImage(withURL: thumbnailUrl, placeholderImage: model.placeholderImage) { (_) in
                    self.model?.image = self.thumbnailView.image
                    self.portraitThumbnail()
                }
            }

            gradientPlayBg.isHidden = model.isPlaying ? false : true
            selectionStyle = .none
            // show thumbnail, and hide logo
            infoButton.isHidden = false

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

        infoButton.setTitleColor(.cerulean, for: .normal)
        infoButton.setTitleColor(.nobel, for: .highlighted)
        portraitThumbnail()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        for label in [detailLabel, subtitleLabel, titleLabel] {
            label?.text = nil
        }

        infoButton.isHidden = true
        thumbnailView.image = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientPlayBg.frame = contentView.bounds
        gradientBg.frame = contentView.bounds
    }

    @IBAction func infoAction(_ sender: UIButton?) {

        if sender == infoButton {
            delegate?.audioTableViewCell(self, infoDidTap: true)
        } else {
            fatalError()
        }
    }

    private func portraitThumbnail() {
        thumbnailView?.layer.borderColor = UIColor.lightGray.cgColor
        thumbnailView?.layer.borderWidth = 1
        if let width = thumbnailView?.layer.bounds.size.width {
            thumbnailView?.layer.cornerRadius = width / 2
        }
        if model?.isPlaying ?? false {
            StreamPlaybackManager.instance.setUpdateImage(thumbnailView.image)
        }
    }

}

protocol AudioTableViewCellDelegate: class {

    func audioTableViewCell(_ cell: AudioTableViewCell, downloadStateDidChange newState: Stream.DownloadState)
    func audioTableViewCell(_ cell: AudioTableViewCell, bookmarkDidChange newState: Bool)
    func audioTableViewCell(_ cell: AudioTableViewCell, infoDidTap newState: Bool)

}
