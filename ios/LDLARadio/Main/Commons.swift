//
//  Commons.swift
//  LDLARadio
//
//  Created by fox on 11/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreGraphics

class Commons {
    
    struct font {
        static let name = "Arial"
        struct size {
            static let XXL : CGFloat = 20
            static let XL : CGFloat = 18
            static let L : CGFloat = 16
            static let M : CGFloat = 14
            static let S : CGFloat = 12
        }
        static let awesome = "FontAwesome"
    }
    
    struct segue {
        static let player = "presentPlayerViewControllerSegueIdentifier"
        static let webView = "presentWebViewControllerSegueIdentifier"
        static let catalog = "recursiveCatalog"
        static let radio = "radioViewController"
    }
    
    public struct symbols {
        // Use https://fontawesome.com/cheatsheet?from=io
        enum FontAwesome : Int {
            case angry = 0xf556
            case ban = 0xf05e
            case cat = 0xf6be
            case certificate = 0xf0a3
            case chevron_up = 0xf077
            case indent = 0xf03c
            case music = 0xf001
        }
        public static func showAwesome(icon: FontAwesome) -> Character {
            return Character(UnicodeScalar(icon.rawValue) ?? "?")
        }
    }
}

