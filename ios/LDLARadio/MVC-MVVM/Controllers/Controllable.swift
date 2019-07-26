//
//  ControllerProtocol.swift
//  LDLARadio
//
//  Created by fox on 26/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Foundation
import UIKit
import JFCore

protocol Controllable {
    
    func numberOfSections() -> Int

    func titleForHeader(inSection section: Int) -> String?
    
    func numberOfRows(inSection section: Int) -> Int
    
    func model(forSection section: Int, row: Int) -> Any?
    
    func heightForRow(at section: Int, row: Int) -> CGFloat
    
    func heightForHeader(at section: Int) -> CGFloat
    
    func title() -> String
    
    func prompt() -> String
    
    func privateRefresh(isClean: Bool, prompt: String, startClosure: (() -> Void)?, finishClosure: ((_ error: JFError?) -> Void)?)
}
