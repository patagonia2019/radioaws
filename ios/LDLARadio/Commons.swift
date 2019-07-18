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
        static let name = "Farah"
        static let size : CGFloat = 12
        static let awesome = "FontAwesome"
    }
    
    struct segue {
        static let player = "presentPlayerViewControllerSegueIdentifier"
        static let webView = "presentWebViewControllerSegueIdentifier"
        static let catalog = "recursiveCatalog"
//        static let audio = "audioViewController"
        static let radio = "radioViewController"
    }
    
    public struct symbols {
        // Use https://fontawesome.com/cheatsheet?from=io
        enum FontAwesome : Int {
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

