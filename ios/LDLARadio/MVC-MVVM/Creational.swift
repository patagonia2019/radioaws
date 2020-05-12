//
//  Creational.swift
//  LDLARadio
//
//  Created by fox on 12/05/2020.
//  Copyright © 2020 Mobile Patagonia. All rights reserved.
//

import Foundation

protocol Creational: Modellable {

    /// Create entity programatically
    static func create() -> ModelType?

}
