//
//  BaseController.swift
//  LDLARadio
//
//  Created by fox on 22/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Foundation
import JFCore

class BaseController {
    var lastUpdated : Date? = nil

    func numberOfSections() -> Int {
        return 1
    }
    
    func titleForHeader(inSection section: Int) -> String? {
        return "Section"
    }
    
    func numberOfRows(inSection section: Int) -> Int {
        return 1
    }
    
    func catalog(forSection section: Int, row: Int) -> Any? {
        return nil
    }
    
    func heightForRow(at section: Int, row: Int) -> CGFloat {
        return 45
    }
    
    func heightForHeader(at section: Int) -> CGFloat {
        return 44
    }
    
    func title() -> String {
        var str = [String]()
        if let updateInfo = lastUpdated?.toInfo() {
            str.append("Updated: ")
            str.append(updateInfo)
        }
        return str.joined()
    }
    
    func prompt() -> String {
        return "Locos de la Azotea"
    }
    
    func refresh(isClean: Bool = false,
                 prompt: String,
                 startClosure: (() -> Void)? = nil,
                 finishClosure: ((_ error: Error?) -> Void)? = nil) {
        
        startClosure?()
        
        CoreDataManager.instance.taskContext?.performAndWait {
            self.privateRefresh(isClean: isClean, prompt: prompt, startClosure: startClosure, finishClosure: finishClosure)
        }
    }

    func privateRefresh(isClean: Bool = false,
                                prompt: String,
                                startClosure: (() -> Void)? = nil,
                                finishClosure: ((_ error: Error?) -> Void)? = nil) {
        
        startClosure?()
        finishClosure?(nil)
    }
}


