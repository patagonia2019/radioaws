//
//  ControllerProtocol.swift
//  LDLARadio
//
//  Created by fox on 26/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import UIKit

/// Protocol is a very powerful feature of the Swift programming language. Protocols are used to define a “blueprint of methods, properties, and other requirements that suit a particular task or piece of functionality.”
protocol Controllable {
    associatedtype ModelType

    func numberOfSections() -> Int

    func numberOfRows(inSection section: Int) -> Int

    func model(forSection section: Int, row: Int) -> ModelType?

    func title() -> String

    func prompt() -> String

    func privateRefresh(isClean: Bool, prompt: String, finishClosure: ((_ error: NSError?) -> Void)?)
}
