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
    @IBOutlet weak var titleButton: UIButton?
    @IBOutlet weak var bookmarkButton: UIButton?
    @IBOutlet weak var infoButton: UIButton?
    @IBOutlet weak var thumbnailView: UIImageView?
    @IBOutlet weak var bgView: UIView?

    var infoBlock: ((_ catalogViewModel: CatalogViewModel?) -> ())? = nil
    var actionExpandBlock: ((_ catalogViewModel: CatalogViewModel?, _ isExpanding: Bool) -> ())? = nil
    var actionBookmarkBlock: ((_ catalogViewModel: CatalogViewModel?, _ isBookmarking: Bool) -> ())? = nil
    
    var model : CatalogViewModel? {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func awakeFromNib() {
        paintBgView()
        expandButton?.setTitleColor(UIColor.aqua, for: .normal)
        expandButton?.setTitleColor(UIColor.blueberry, for: .highlighted)
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
        titleButton?.titleLabel?.numberOfLines = 3
        titleButton?.titleLabel?.lineBreakMode = .byTruncatingTail

        if let model = model {
            if let isExpanded = model.isExpanded {
                expandButton?.isHidden = false
                expandButton?.isHighlighted = !isExpanded
            }
            else {
                expandButton?.isHidden = true
            }
            
            thumbnailView?.isHidden = true
            if let thumbnailUrl = model.thumbnailUrl {
                thumbnailView?.af_setImage(withURL: thumbnailUrl) { (response) in
                    if response.error == nil {
                        self.thumbnailView?.isHidden = false
                    }
                }
            }
            infoButton?.isHidden = !(model.text?.count ?? 0 > 0)
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
        setNeedsLayout()
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

    private func paintBgView() {
        let gradientBg2 = CAGradientLayer()
        gradientBg2.startPoint = CGPoint.init(x: 0, y: 1)
        gradientBg2.endPoint = CGPoint.init(x: 1, y: 1)
        gradientBg2.colors = [UIColor.white.cgColor, UIColor.lightGray.cgColor]
        if let bgView = bgView {
            gradientBg2.frame = bgView.bounds
            bgView.layer.insertSublayer(gradientBg2, at: 0)
        }
    }

}




