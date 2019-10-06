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

    static func isPad() -> Bool {
        return UIScreen.main.traitCollection.userInterfaceIdiom == .pad
    }

    enum Toolbar: Int {
        typealias RawValue = Int
        case spinner = 1001
        case image
        case bigImage
        case slider
        case bigCurrentTime
        case message
        case currentTime
        case totalTime
        case playPause
        case info
        case bookmark
    }

    struct Size {
        static let toolbarHeight: CGFloat = isPad() ? 120 : 70
        static let toolbarSpinnerSize: CGSize = CGSize(width: toolbarHeight - 2, height: toolbarHeight - 2)
        static let toolbarImageSize: CGSize = CGSize(width: toolbarHeight - 2, height: toolbarHeight - 2)
        static let toolbarLabelWidth: CGFloat = isPad() ? 100 : 50
        static let toolbarButtonFontSize: CGFloat = isPad() ? 50 : 30
    }

    struct Font {
        static let regular = "Arial"
        static let bold = "Arial-BoldMT"
        struct Size {
            static let XXXXL: CGFloat = isPad() ? 60 : 50
            static let XXXL: CGFloat = isPad() ? 40 : 36
            static let XXL: CGFloat = isPad() ? 36 : 32
            static let XL: CGFloat = isPad() ? 32 : 28
            static let L: CGFloat = isPad() ? 28 : 24
            static let M: CGFloat = isPad() ? 26 : 20
            static let S: CGFloat = isPad() ? 22 : 16
            static let XS: CGFloat = isPad() ? 18 : 12
            static let XXS: CGFloat = isPad() ? 14 : 8
        }
        static let awesome = "FontAwesome"
    }

    struct Segue {
        static let catalog = "recursiveCatalog"
        static let archiveorg = "recursiveArchiveOrg"
        static let search = "searchAudio"
        static let radio = "radioViewController"
    }

    public struct Symbol {
        // Use https://fontawesome.com/cheatsheet?from=io
        enum FontAwesome: Int {
            case angry = 0xf556
            case ban = 0xf05e
            case battery_empty = 0xf244
            case bug = 0xf188
            case cat = 0xf6be
            case certificate = 0xf0a3
            case chevron_up = 0xf077
            case heart = 0xf004
            case indent = 0xf03c
            case info_circle = 0xf05a
            case music = 0xf001
            case pause_circle = 0xf28b
            case play_circle = 0xf144
            case trash = 0xf1f8
        }
        public static func showAwesome(icon: FontAwesome) -> Character {
            return Character(UnicodeScalar(icon.rawValue) ?? "?")
        }
    }
}
