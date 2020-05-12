//
//  BaseController.swift
//  LDLARadio
//
//  Created by fox on 22/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import JFCore

class BaseController: Controllable {

    var lastUpdated: Date?
    var finishBlock: ((_ error: JFError?) -> Void)?
    static var isBookmarkChanged = false

    var useRefresh: Bool {
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

    func modelInstance(inSection section: Int) -> SectionViewModel? {
        return nil
    }

    func play(forSection section: Int, row: Int) {
        
        let stream = StreamPlaybackManager.instance
        
        guard let audio = model(forSection: section, row: row) as? AudioViewModel else { return }
    
        var shouldPlay = true
        if stream.isPlaying() {
            shouldPlay = stream.urlString() != audio.urlString()

            stream.setAudioForPlayback(nil, nil)
        }
        Analytics.logFunction(function: "embeddedplay",
                              parameters: ["audio": audio.title.text as AnyObject,
                                           "section": audio.section as AnyObject,
                                           "url": audio.urlString() as AnyObject])
        
        guard let context = RestApi.instance.context else { fatalError() }
        var tmpAudioPlay: Audio?
        context.performAndWait {
            // TODO: fix but sometimes add the same playing audio as bookmarked
            tmpAudioPlay = Audio.search(byUrl: audio.url?.absoluteString)
            if tmpAudioPlay == nil {
                tmpAudioPlay = Audio.create()
            }
            tmpAudioPlay?.cloudSynced = false
            if var tmpAudioPlay = tmpAudioPlay {
                tmpAudioPlay += audio
            }
            CoreDataManager.instance.save()
        }
        if shouldPlay {
            stream.setAudioForPlayback(tmpAudioPlay, audio.image)
        }
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

    func expand(model: SectionViewModel?,
                section: Int,
                incrementPage: Bool = false,
                startClosure: (() -> Void)? = nil,
                finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        RestApi.instance.context?.performAndWait {
            self.expanding(model: model, section: section, incrementPage: incrementPage, startClosure: startClosure, finishClosure: finishClosure)
        }
    }

    internal func expanding(model: SectionViewModel?, section: Int, incrementPage: Bool, startClosure: (() -> Void)? = nil, finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        fatalError()
    }

    internal func privateRefresh(isClean: Bool = false,
                                 prompt: String,
                                 finishClosure: ((_ error: JFError?) -> Void)? = nil) {

        fatalError()
    }

    func changeBookmark(indexPath: IndexPath, isReload: Bool = true) {
        let object = model(forSection: indexPath.section, row: indexPath.row)
        if let model = object as? AudioViewModel {
            Audio.changeAudioBookmark(model: model)
        } else if let model = object as? SectionViewModel {
            Audio.changeCatalogBookmark(model: model)
        } else {
            fatalError()
        }
    }

}
