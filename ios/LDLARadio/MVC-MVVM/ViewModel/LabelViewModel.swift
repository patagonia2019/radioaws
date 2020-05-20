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
    var text: String?
    var color: UIColor = UIColor.midnight
    var font: UIFont? = UIFont(name: Commons.Font.bold, size: Commons.Font.Size.S)
    var isHidden: Bool = false
    var lines: Int = 1

    var count: Int {
        return text?.count ?? 0
    }
    
    var isEmpty: Bool {
        return text?.isEmpty ?? false
    }
}

extension LabelViewModel {
    static func < (left: LabelViewModel, right: LabelViewModel) -> Bool {
        guard let leftText = left.text, let rightText = right.text else {
            return false
        }
        return leftText < rightText
    }
}
