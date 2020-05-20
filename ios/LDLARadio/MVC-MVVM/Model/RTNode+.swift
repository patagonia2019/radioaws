//
//  RTNode+.swift
//  LDLARadio
//
//  Created by fox on 19/05/2020.
//  Copyright © 2020 Mobile Patagonia. All rights reserved.
//

import Foundation

extension RTNode {
    
    static func += (left: inout RTNode, right: RTNode) {
        left.element = right.element
        left.text = right.text
        left.type = right.type
        left.url = right.url
    }

}
