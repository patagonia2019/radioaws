//
//  BaseController.swift
//  LDLARadio
//
//  Created by fox on 22/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Foundation
import JFCore

class BaseController : Controllable {
    var lastUpdated : Date? = nil
    var finishBlock: ((_ error: JFError?) -> ())? = nil

    var useRefresh : Bool {
        return true
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func titleForHeader(inSection section: Int) -> String? {
        return "Section"
    }
    
    func numberOfRows(inSection section: Int) -> Int {
        return 1
    }
    
    func model(forSection section: Int, row: Int) -> Any? {
        fatalError()
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
        return "Los Locos de la Azotea"
    }
    
    func refresh(isClean: Bool = false,
                 prompt: String = "",
                 startClosure: (() -> Void)? = nil,
                 finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        
        finishBlock = finishClosure
        
        startClosure?()
        
        RestApi.instance.context?.performAndWait {
            self.privateRefresh(isClean: isClean, prompt: prompt, startClosure: startClosure, finishClosure: finishClosure)
        }
    }

    func privateRefresh(isClean: Bool = false,
                                prompt: String,
                                startClosure: (() -> Void)? = nil,
                                finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        
        startClosure?()
        finishClosure?(nil)
    }
    
    func changeBookmark(at section: Int, row: Int) {
        guard var model = model(forSection: section, row: row) as? AudioViewModel else {
            return
        }
        
        guard let context = RestApi.instance.context else {
            fatalError("fatal: no core data context manager")
        }
        
        context.performAndWait {
            if let id = model.id,
                let url = model.url?.absoluteString {
                if let bookmark = Bookmark.fetch(id: id, url: url) {
                    bookmark.remove()
                }
                else {
                    if var
                        bookmark = Bookmark.create() {
                        bookmark += model
                    }
                }
                model.isBookmarked = !model.isBookmarked
                CoreDataManager.instance.save()
                refresh(finishClosure: finishBlock)
            }
        }
    }
}


