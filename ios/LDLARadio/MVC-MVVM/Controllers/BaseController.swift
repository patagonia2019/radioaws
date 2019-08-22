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
    static var isBookmarkChanged = false

    var useRefresh : Bool {
        return true
    }
    
    func numberOfSections() -> Int {
        return 1
    }
        
    func numberOfRows(inSection section: Int) -> Int {
        return 1
    }
    
    func model(forSection section: Int, row: Int) -> Any? {
        fatalError()
    }
    
    func modelInstance(inSection section: Int) -> CatalogViewModel? {
        return nil
    }

    func play(forSection section: Int, row: Int) {

        if let audio = model(forSection: section, row: row) as? AudioViewModel,
            audio.isPlaying == false {
            
            for j in 0..<numberOfSections() {
                for k in 0..<numberOfRows(inSection: j) {
                    if let other = model(forSection: j, row: k) as? AudioViewModel {
                        if other.isPlaying {
                            if other.urlString() != audio.urlString() {
                                StreamPlaybackManager.instance.setAudioForPlayback(nil)
                                other.isPlaying = false
                            }
                        }
                    }
                }
            }
            audio.isPlaying = true
            
            Analytics.logFunction(function: "embeddedplay",
                                  parameters: ["audio": audio.title.text as AnyObject,
                                               "section": audio.section as AnyObject,
                                               "url": audio.urlString() as AnyObject])
            
            guard let context = RestApi.instance.context else { fatalError() }
            
            context.performAndWait {
                
                var tmpAudioPlay = AudioPlay.search(byUrl: audio.url?.absoluteString)
                if tmpAudioPlay == nil {
                    tmpAudioPlay = AudioPlay.create()
                }
                if var tmpAudioPlay = tmpAudioPlay {
                    tmpAudioPlay += audio
                    CloudKitManager.instance.save(audioPlay: tmpAudioPlay) { error in
                    }
                    
                    StreamPlaybackManager.instance.setAudioForPlayback(tmpAudioPlay)
                }
                if useRefresh {
                    CoreDataManager.instance.save()
                }
            }
        }
    }

    func heightForRow(at section: Int, row: Int) -> CGFloat {
        return 45
    }
    
    func heightForHeader(at section: Int) -> CGFloat {
        return CGFloat(CatalogViewModel.cellheight)*1.5
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
    
    func expand(model: CatalogViewModel?, section: Int,
                incrementPage: Bool = false,
                startClosure: (() -> Void)? = nil,
                finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        RestApi.instance.context?.performAndWait {
            self.expanding(model: model, section: section, incrementPage: incrementPage, startClosure: startClosure, finishClosure: finishClosure)
        }
    }

    internal func expanding(model: CatalogViewModel?, section: Int, incrementPage: Bool, startClosure: (() -> Void)? = nil, finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        fatalError()
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
        BaseController.isBookmarkChanged = true

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

