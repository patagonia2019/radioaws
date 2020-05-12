//
//  Sectionable.swift
//  LDLARadio
//
//  Created by fox on 12/05/2020.
//  Copyright © 2020 Mobile Patagonia. All rights reserved.
//

import Foundation
import UIKit

protocol Sectionable {
    associatedtype SectionModelType
    var sectionIdentifier: String { get }
    var titleText: String? { get }
    var subTitleText: String? { get }
    var detailText: String? { get }
    var infoText: String? { get }
    var placeholderImage: UIImage? { get }
    var portraitUrl: URL? { get }

    var isCollapsed: Bool { get }
    var parentId: String? { get }
    var sectionDetailText: String? { get }
    var queryUrl: URL? { get }
    var content: ([SectionModelType], [SectionModelType]) { get }
}
