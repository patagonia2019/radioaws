//
//  BaseViewModelProtocol.swift
//  LDLARadio
//
//  Created by fox on 02/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import UIKit

protocol BaseViewModelProtocol {
    
    /// Some constants hardcoded here    
    var icon: Commons.symbols.FontAwesome { get }
    var iconColor: UIColor { get }
    var url: URL? { get set }
    var selectionStyle: UITableViewCell.SelectionStyle { get set }
    var accessoryType : UITableViewCell.AccessoryType { get set }
    var title : LabelViewModel { get set }
    var detail : LabelViewModel { get set }
    var isBookmarked: Bool? { get set }
    var section : String { get set }
}

