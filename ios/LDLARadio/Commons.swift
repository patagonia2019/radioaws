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
    }
    
    public struct Symbols {
        // Use https://fontawesome.com/cheatsheet?from=io
        enum FontAwesome : Int {
            case angle_down = 0xf107
            case angle_left = 0xf104
            case bars = 0xf0c9
            case camera = 0xf030
            case check = 0xf00c
            case chevron_down = 0xf078
            case chevron_right = 0xf054
            case comment = 0xf075
            case download = 0xf019
            case film = 0xf008
            case music = 0xf001
            case play_circle = 0xf144
            case plus = 0xf067
            case save = 0xf0c7
            case spinner = 0xf110
            case trash_alt = 0xf1f8
            case undo = 0xf0e2
            case upload = 0xf093
            case warning = 0xf071
            case wifi = 0xf1eb
        }
        public static func showAwesome(icon: FontAwesome) -> Character {
            return Character(UnicodeScalar(icon.rawValue) ?? "?")
        }
    }
}

