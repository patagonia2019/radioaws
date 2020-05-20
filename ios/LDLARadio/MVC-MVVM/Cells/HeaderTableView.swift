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

    @IBOutlet private weak var leadingConstraint: NSLayoutConstraint?
    @IBOutlet private weak var separatorView: UIView?
    @IBOutlet private weak var expandButton: UIButton?
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var infoButton: UIButton?
    @IBOutlet private weak var thumbnailView: UIImageView?

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
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel?.text = nil
        expandButton?.isHidden = true
        expandButton?.isHighlighted = false
        thumbnailView?.image = nil
        infoButton?.isHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let model = model else { return }
        
        titleLabel?.text = model.title.text
        titleLabel?.textColor = model.title.color
        titleLabel?.font = model.title.font

        if let isCollapsed = model.isCollapsed {
            expandButton?.isHidden = false
            expandButton?.isHighlighted = isCollapsed
            separatorView?.isHidden = !isCollapsed
        } else {
            expandButton?.isHidden = true
            leadingConstraint?.constant = 6
            separatorView?.isHidden = true
        }
        
        thumbnailView?.image = model.placeholderImage
        if let thumbnailUrl = model.thumbnailUrl {
            thumbnailView?.af_setImage(withURL: thumbnailUrl, placeholderImage: model.placeholderImage)
        }
        
        infoButton?.isHidden = model.text?.isEmpty ?? true
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
}
