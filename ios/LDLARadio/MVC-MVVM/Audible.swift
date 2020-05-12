//
//  Audible.swift
//  LDLARadio
//
//  Created by fox on 05/05/2020.
//  Copyright © 2020 Mobile Patagonia. All rights reserved.
//

import Foundation
import UIKit

protocol Audible {
    var audioIdentifier: String { get }
    var titleText: String? { get }
    var subTitleText: String? { get }
    var detailText: String? { get }
    var infoText: String? { get }
    var placeholderImage: UIImage? { get }
    var portraitUrl: URL? { get }
    var audioUrl: URL? { get }
}
