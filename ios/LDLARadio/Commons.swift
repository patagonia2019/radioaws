//
//  Commons.swift
//  LDLARadio
//
//  Created by fox on 11/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Foundation
import CoreGraphics

class Commons {
    
    struct font {
        static let name = "Arial"
        static let size : CGFloat = 12
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
            case certificate = 0xf0a3
            case chevron_up = 0xf077
            case indent = 0xf03c
            case music = 0xf001
            case angry = 0xf556
            case cat = 0xf6be
            case ban = 0xf05e
        }
        public static func showAwesome(icon: FontAwesome) -> Character {
            return Character(UnicodeScalar(icon.rawValue) ?? "?")
        }
    }
}

