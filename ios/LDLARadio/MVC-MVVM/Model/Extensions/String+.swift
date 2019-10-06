//
//  String+.swift
//  LDLARadio
//
//  Created by fox on 22/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import UIKit

extension String {
    /// AttributeString converstion from String
    func bigRed() -> NSAttributedString {
        let font = UIFont.init(name: Commons.Font.bold, size: Commons.Font.Size.S)
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.red,
                          NSAttributedString.Key.font: font as Any]
        return NSAttributedString(string: self, attributes: attributes)
    }

    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    func html2String() -> String {
        return html2AttributedString?.string ?? self
    }

}
