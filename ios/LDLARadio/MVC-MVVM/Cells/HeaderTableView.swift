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
class HeaderTableView: UITableViewHeaderFooterView {
    static let reuseIdentifier: String = "HeaderTableView"

    @IBOutlet weak var separatorView: UIView?
    @IBOutlet weak var expandButton: UIButton?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var infoButton: UIButton?
    @IBOutlet weak var thumbnailView: UIImageView?
    let gradientBg = CAGradientLayer()

    var infoBlock: ((_ catalogViewModel: SectionViewModel?) -> Void)?
    var actionExpandBlock: ((_ catalogViewModel: SectionViewModel?, _ isExpanding: Bool) -> Void)?

    var model: SectionViewModel? {
        didSet {
            setNeedsLayout()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        expandButton?.setTitleColor(UIColor.tangerine, for: .normal)
        expandButton?.setTitleColor(UIColor.plum, for: .highlighted)
        portraitThumbnail()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel?.text = nil
        expandButton?.isHidden = true
        expandButton?.isHighlighted = false
        thumbnailView?.isHidden = true
        infoButton?.isHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.text = model?.title.text
        titleLabel?.textColor = model?.title.color
        titleLabel?.font = model?.title.font

        if let model = model {
            if let isCollapsed = model.isCollapsed {
                expandButton?.isHidden = false
                expandButton?.isHighlighted = isCollapsed
            } else {
                expandButton?.isHidden = true
            }

            thumbnailView?.isHidden = true
            if let thumbnailUrl = model.thumbnailUrl {
                thumbnailView?.af_setImage(withURL: thumbnailUrl) { (response) in
                    if response.error == nil {
                        self.thumbnailView?.isHidden = false
                        self.portraitThumbnail()
                    }
                }
            }
            infoButton?.isHidden = model.text?.isEmpty ?? false
        }
    }

    static func setup(tableView: UITableView?) {
        let headerNib = UINib.init(nibName: nibName(), bundle: Bundle.main)
        tableView?.register(headerNib, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
    }

    class func nibName() -> String {
        return "Main"
    }

    @IBAction func infoAction(_ sender: Any) {
        infoBlock?(model)
    }

    @IBAction func expandAction(_ sender: Any) {
        if expandButton?.isHidden == true {
            return
        }

        setNeedsLayout()
        if let expandButton = expandButton {
            expandButton.isHighlighted = !expandButton.isHighlighted
            actionExpandBlock?(model, expandButton.isHighlighted)
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
