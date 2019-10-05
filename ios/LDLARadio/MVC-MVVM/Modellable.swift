//
//  Modellable.swift
//  LDLARadio
//
//  Created by fox on 26/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import AVFoundation
import CoreData
import JFCore

protocol Modellable {

    associatedtype ModelType

    /// Update the `updatedAt` field in the entity when the model is created
    func awakeFromInsert() // -> normally implemented in Model+ extension

    /// Fetch the most recent updatedAt date
    static func lastUpdated() -> Date? // -> normally implemented in Model+ extension

    /// Function to obtain all the instance of the model
    static func all() -> [ModelType]?

    /// Remove all the instances of the entity
    static func clean()

    /// Remove the current instance of the Entity
    func remove() // -> normally implemented in Model+ extension

}

protocol Creational: Modellable {

    /// Create entity programatically
    static func create() -> ModelType?

}
