//
//  CatalogViewModel.swift
//  LDLARadio
//
//  Created by fox on 13/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Foundation
import UIKit

// This view model will be responsible of render out information in the views for Catalog info
struct CatalogViewModel {
    
    /// Some constants hardcoded here
    public struct hardcode {
        static let cellheight: CGFloat = 70
        static let identifier: String = "CatalogIdentifier"
    }
    
    private var icon: Commons.symbols.FontAwesome = .indent
    var detail: String
    let height: CGFloat = hardcode.cellheight
    let color: UIColor = .black
    let selectionStyle: UITableViewCell.SelectionStyle = .blue
    let font: UIFont? = UIFont(name: Commons.font.name, size: Commons.font.size)
    var accessoryType : UITableViewCell.AccessoryType = .none
    var url: URL? = nil
    var title: String
    var sections: [CatalogViewModel]? = nil
    
    init(catalog: RTCatalog?) {
        title = catalog?.catalog?.title ?? ""
        detail = catalog?.text ?? catalog?.title ?? ""
        if let queryUrl = catalog?.url {
            if let urlChecked = URL(string: queryUrl),
                UIApplication.shared.canOpenURL(urlChecked) {
                url = urlChecked
                accessoryType = .disclosureIndicator
            }
        }
        if let innerSections = catalog?.sections?.allObjects {
            sections = innerSections.map { return CatalogViewModel(catalog: $0 as? RTCatalog) }
        }
    }
    
    func iconText() -> String {
        return "\(Commons.symbols.showAwesome(icon: icon))"
    }
    
}
