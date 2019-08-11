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

    func play(forSection section: Int, row: Int) {
        if let model = model(forSection: section, row: row) as? AudioViewModel {
            if model.isPlaying {
                model.stop()
            }
            else {
                model.play()
            }
        }
        for s in 0..<numberOfSections() {
            for r in 0..<numberOfRows(inSection: s) {
                if s == section && r == row {
                    continue
                }
                if let model = model(forSection: s, row: r) as? AudioViewModel {
                    model.sizeReset()
                }
            }
        }
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
        
        RestApi.instance.context?.performAndWait {
            startClosure?()
            self.privateRefresh(isClean: isClean, prompt: prompt, finishClosure: finishClosure)
        }
    }

    internal func privateRefresh(isClean: Bool = false,
                                prompt: String,
                                finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        
        fatalError()
    }

    func changeCatalogBookmark(model: CatalogViewModel?) {
        guard let context = RestApi.instance.context else { fatalError() }
        guard let model = model else {
            return
        }
        for audio in model.audios {
            changeAudioBookmark(model: audio, useRefresh: false)
        }
        context.performAndWait {
            CoreDataManager.instance.save()
            refresh(finishClosure: finishBlock)
        }

    }
    

    func changeCatalogBookmark(at section: Int, row: Int) {
        changeCatalogBookmark(model: model(forSection: section, row: row) as? CatalogViewModel)
    }

    func changeAudioBookmark(model: AudioViewModel?, useRefresh: Bool = true) {

        guard let context = RestApi.instance.context else { fatalError() }
        guard let model = model else { return }
        
        context.performAndWait {
            var action : String = "*"
            if let bookmark = Bookmark.search(byUrl: model.url?.absoluteString) {
                bookmark.remove()
                CloudKitManager.instance.remove(bookmark: bookmark, finishClosure: finishBlock)
                action = "-"
            }
            else if var bookmark = Bookmark.create() {
                action = "+"
                bookmark += model
                CloudKitManager.instance.save(bookmark: bookmark, finishClosure: finishBlock)
            }
            else {
                fatalError()
            }
            Analytics.logFunction(function: "bookmark",
                                  parameters: ["action": action as AnyObject,
                                               "title": model.title.text as AnyObject,
                                               "section": model.section as AnyObject,
                                               "url": model.urlString() as AnyObject])

            if useRefresh {
                CoreDataManager.instance.save()
            }
        }
    }

    func changeAudioBookmark(at section: Int, row: Int) {
        if let model = model(forSection: section, row: row) as? AudioViewModel {
            changeAudioBookmark(model: model)
            model.isBookmarked = !(model.isBookmarked ?? false)
        }
    }
    
}

