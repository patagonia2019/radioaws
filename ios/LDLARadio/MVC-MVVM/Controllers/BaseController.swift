//
//  BaseController.swift
//  LDLARadio
//
//  Created by fox on 22/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
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
        return ""
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

    internal func privateRefresh(isClean: Bool = false,
                                prompt: String,
                                startClosure: (() -> Void)? = nil,
                                finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        
        startClosure?()
        finishClosure?(nil)
    }

    func changeCatalogBookmark(model: CatalogViewModel?) {
        guard let context = RestApi.instance.context else { fatalError() }
        guard let model = model else {
            return
        }
        for audio in model.audios {
            changeAudioBookmark(model: audio, useRefresh: false, section: model.tree)
        }
        context.performAndWait {
            CoreDataManager.instance.save()
            refresh(finishClosure: finishBlock)
        }

    }
    

    func changeCatalogBookmark(at section: Int, row: Int) {
        changeCatalogBookmark(model: model(forSection: section, row: row) as? CatalogViewModel)
    }

    func changeAudioBookmark(model: AudioViewModel?, useRefresh: Bool = true, section: String? = nil) {

        guard let context = RestApi.instance.context else { fatalError() }
        guard var model = model else { return }
        
        context.performAndWait {
            if let bookmark = Bookmark.search(byUrl: model.url?.absoluteString) {
                bookmark.remove()
            }
            else if var bookmark = Bookmark.create() {
                bookmark += model
                bookmark.section = section
            }
            else {
                fatalError()
            }
            model.isBookmarked = !model.isBookmarked
            if useRefresh {
                CoreDataManager.instance.save()
                refresh(finishClosure: finishBlock)
            }
        }
    }

    func changeAudioBookmark(at section: Int, row: Int) {
        changeAudioBookmark(model: model(forSection: section, row: row) as? AudioViewModel)
    }
}


