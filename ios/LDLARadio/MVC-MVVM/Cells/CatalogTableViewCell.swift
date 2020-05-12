//
//  CatalogTableViewCell.swift
//  LDLARadio
//
//  Created by fox on 13/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import UIKit

class CatalogTableViewCell: UITableViewCell {
    static let reuseIdentifier: String = "CatalogTableViewCell"

    @IBOutlet weak var iconView: UILabel!
    @IBOutlet weak var detailView: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var infoButton: UIButton!

    var infoBlock: ((_ catalogViewModel: CatalogViewModel?) -> Void)?
    var actionBookmarkBlock: ((_ catalogViewModel: CatalogViewModel?, _ isBookmarking: Bool) -> Void)?

    var model: CatalogViewModel? = nil {
        didSet {
            guard let model = model else { return }
            bookmarkButton.isHidden = true
            infoButton.isHidden = !(model.text?.isEmpty ?? false)

            iconView.text = model.iconText()
            iconView.textColor = model.iconColor
            detailView.text = model.title.text
            detailView.textColor = model.title.color
            detailView.font = model.title.font
            selectionStyle = model.selectionStyle
            accessoryType = model.accessoryType
            
            thumbnailView.image = model.placeholderImage
            if let thumbnailUrl = model.thumbnailUrl {
                thumbnailView.isHidden = false
                iconView.isHidden = true
                thumbnailView.af_setImage(withURL: thumbnailUrl, placeholderImage: model.placeholderImage) { (response) in
                    if response.error != nil {
                        self.iconView.isHidden = false
                        self.thumbnailView.isHidden = true
                    } else {
                        self.portraitThumbnail()
                    }
                }
            } else {
                thumbnailView.isHidden = true
                iconView.isHidden = false
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        portraitThumbnail()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconView.text = "\(Commons.Symbol.showAwesome(icon: .battery_empty))"
        iconView.textColor = .red
        thumbnailView.isHidden = true
        iconView.isHidden = true
        detailView.text = nil
        detailView.textColor = .red
        selectionStyle = .none
        accessoryType = .none
        bookmarkButton.isHidden = true
        bookmarkButton.isHighlighted = false
        infoButton.isHidden = true
    }

    @IBAction func bookmarkAction(_ sender: UIButton?) {

        if sender == bookmarkButton {
            bookmarkButton.isHighlighted = !bookmarkButton.isHighlighted
            actionBookmarkBlock?(model, bookmarkButton.isHighlighted)
        } else {
            fatalError()
        }
    }
    @IBAction func infoAction(_ sender: UIButton?) {

        if sender == infoButton {
            infoBlock?(model)
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
    }

}
