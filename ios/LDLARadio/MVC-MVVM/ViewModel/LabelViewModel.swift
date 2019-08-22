//
//  LabelViewModel.swift
//  LDLARadio
//
//  Created by fox on 02/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import UIKit

struct LabelViewModel {
    /// title specification
    var text: String = ""
    var color: UIColor = UIColor.midnight
    var font: UIFont? = UIFont(name: Commons.font.name, size: Commons.font.size.L)
    var isHidden: Bool = false
    var lines: Int = 1
    
    var count : Int {
        return text.count
    }
}
