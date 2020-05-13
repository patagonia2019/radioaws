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

    @IBOutlet weak var expandButton: UIButton?
    @IBOutlet weak var titleButton: UIButton?
    @IBOutlet weak var bookmarkButton: UIButton?
    @IBOutlet weak var infoButton: UIButton?
    @IBOutlet weak var thumbnailView: UIImageView?
    @IBOutlet weak var bgView: UIView?
    let gradientBg = CAGradientLayer()

    var infoBlock: ((_ catalogViewModel: SectionViewModel?) -> Void)?
    var actionExpandBlock: ((_ catalogViewModel: SectionViewModel?, _ isExpanding: Bool) -> Void)?
    var actionBookmarkBlock: ((_ catalogViewModel: SectionViewModel?, _ isBookmarking: Bool) -> Void)?

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
        titleButton?.setTitle("", for: .normal)
        expandButton?.isHidden = true
        expandButton?.isHighlighted = false
        bookmarkButton?.isHidden = true
        bookmarkButton?.isHighlighted = false
        thumbnailView?.isHidden = true
        infoButton?.isHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        titleButton?.setTitle(model?.title.text, for: .normal)
        titleButton?.setTitleColor(model?.title.color, for: .normal)
        titleButton?.titleLabel?.font = model?.title.font
        titleButton?.titleLabel?.numberOfLines = 0

        if let bgView = bgView {
            gradientBg.frame = bgView.bounds
        }

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

    @IBAction func bookmarkAction(_ sender: UIButton?) {

        if let bookmarkButton = bookmarkButton {
            bookmarkButton.isHighlighted = !bookmarkButton.isHighlighted
            actionBookmarkBlock?(model, bookmarkButton.isHighlighted)
        } else {
            fatalError()
        }
    }

    private func paintBgView() {
        gradientBg.startPoint = CGPoint.init(x: 0, y: 1)
        gradientBg.endPoint = CGPoint.init(x: 1, y: 1)
        gradientBg.colors = [UIColor.magnesium.cgColor, UIColor.mercury.cgColor]
        if let bgView = bgView {
            gradientBg.frame = bgView.bounds
            bgView.layer.insertSublayer(gradientBg, at: 0)
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
