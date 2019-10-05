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

    func modelInstance(inSection section: Int) -> CatalogViewModel? {
        return nil
    }

    func play(forSection section: Int, row: Int) {

        if let audio = model(forSection: section, row: row) as? AudioViewModel {

            if audio.isPlaying == false {

                for j in 0..<numberOfSections() {
                    for k in 0..<numberOfRows(inSection: j) {
                        if let other = model(forSection: j, row: k) as? AudioViewModel {
                            if other.isPlaying {
                                if other.urlString() != audio.urlString() {
                                    other.isPlaying = false
                                    StreamPlaybackManager.instance.setAudioForPlayback(nil, nil)
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

                    var tmpAudioPlay = Audio.search(byUrl: audio.url?.absoluteString)
                    if tmpAudioPlay == nil {
                        tmpAudioPlay = Audio.create()
                    }
                    tmpAudioPlay?.cloudSynced = false
                    if var tmpAudioPlay = tmpAudioPlay {
                        tmpAudioPlay += audio
                        StreamPlaybackManager.instance.setAudioForPlayback(tmpAudioPlay, audio.image)
                    }
                    CoreDataManager.instance.save()
                }
            } else {
                guard let context = RestApi.instance.context else { fatalError() }
                
                context.performAndWait {
                    audio.isPlaying = false
                    CoreDataManager.instance.save()
                }
                
                StreamPlaybackManager.instance.setAudioForPlayback(nil, nil)
            }
        }
    }

    func heightForRow(at section: Int, row: Int) -> CGFloat {
        return 45
    }

    func heightForHeader(at section: Int) -> CGFloat {
        return CGFloat(CatalogViewModel.cellheight)
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
    
    func changeBookmark(indexPath: IndexPath, isReload: Bool = true) {
        let object = model(forSection: indexPath.section, row: indexPath.row)
        if let model = object as? AudioViewModel {
            Audio.changeAudioBookmark(model: model)
        }
        else if let model = object as? CatalogViewModel {
            Audio.changeCatalogBookmark(model: model)
        }
        else {
            fatalError()
        }
    }
    
}
