//
//  String+.swift
//  LDLARadio
//
//  Created by fox on 22/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import UIKit

extension String {
    func bigRed() -> NSAttributedString {
        let font = UIFont.init(name: Commons.font.name, size: Commons.font.size.S)
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.red,
                          NSAttributedString.Key.font:font as Any]
        return NSAttributedString(string: self, attributes: attributes)
    }
}
