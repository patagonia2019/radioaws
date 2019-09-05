//
//  Commons.swift
//  LDLARadio
//
//  Created by fox on 11/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

class Commons {

    enum toolBar: Int {
        typealias RawValue = Int
        case spinner = 1001
        case image
        case slider
        case currentTime
        case totalTime
        case playPause
        case info
        case bookmark
    }
    
    struct size {
        static let toolbarHeight: CGFloat = UIScreen.main.traitCollection.userInterfaceIdiom == .pad ? 120 : 56
        static let toolbarSpinnerSize: CGSize = UIScreen.main.traitCollection.userInterfaceIdiom == .pad ? CGSize(width: 100, height: 100) : CGSize(width: 40, height: 40)
        static let toolbarImageSize: CGSize = UIScreen.main.traitCollection.userInterfaceIdiom == .pad ? CGSize(width: 100, height: 100) : CGSize(width: 34, height: 34)
        static let toolbarLabelWidth: CGFloat = UIScreen.main.traitCollection.userInterfaceIdiom == .pad ? 100 : 50
        static let toolbarButtonFontSize: CGFloat = UIScreen.main.traitCollection.userInterfaceIdiom == .pad ? 50 : 30
    }

    struct font {
        static let name = "Arial"
        struct size {
            static let XXXL: CGFloat = UIScreen.main.traitCollection.userInterfaceIdiom == .pad ? 40 : 36
            static let XXL: CGFloat = UIScreen.main.traitCollection.userInterfaceIdiom == .pad ? 36 : 32
            static let XL: CGFloat = UIScreen.main.traitCollection.userInterfaceIdiom == .pad ? 32 : 28
            static let L: CGFloat = UIScreen.main.traitCollection.userInterfaceIdiom == .pad ? 28 : 24
            static let M: CGFloat = UIScreen.main.traitCollection.userInterfaceIdiom == .pad ? 26 : 20
            static let S: CGFloat = UIScreen.main.traitCollection.userInterfaceIdiom == .pad ? 22 : 16
            static let XS: CGFloat = UIScreen.main.traitCollection.userInterfaceIdiom == .pad ? 18 : 12
            static let XXS: CGFloat = UIScreen.main.traitCollection.userInterfaceIdiom == .pad ? 14 : 8
        }
        static let awesome = "FontAwesome"
    }

    struct segue {
        static let catalog = "recursiveCatalog"
        static let archiveorg = "recursiveArchiveOrg"
        static let search = "searchAudio"
        static let radio = "radioViewController"
    }

    public struct symbols {
        // Use https://fontawesome.com/cheatsheet?from=io
        enum FontAwesome: Int {
            case angry = 0xf556
            case apple_alt = 0xf5d1
            case ban = 0xf05e
            case battery_empty = 0xf244
            case bug = 0xf188
            case cat = 0xf6be
            case certificate = 0xf0a3
            case chevron_up = 0xf077
            case indent = 0xf03c
            case info_circle = 0xf05a
            case music = 0xf001
            case pause_circle = 0xf28b
            case play_circle = 0xf144
        }
        public static func showAwesome(icon: FontAwesome) -> Character {
            return Character(UnicodeScalar(icon.rawValue) ?? "?")
        }
    }
}
