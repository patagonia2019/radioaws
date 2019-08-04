//
//  SearchController.swift
//  LDLARadio
//
//  Created by fox on 03/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import JFCore

class SearchController: BaseController {
    
    /// Notification for when bookmark has changed.
    static let didRefreshNotification = NSNotification.Name(rawValue: "SearchController.didRefreshNotification")
    
    var models = [[AudioViewModel](), [AudioViewModel](), [AudioViewModel](), [AudioViewModel]()]
    var textToSearch = String()
    
    override var useRefresh : Bool {
        return true
    }
    
    override init() {
    }

    init(withText text: String?) {
        textToSearch = text ?? ""
    }
    
    override func prompt() -> String {
        return "Search: \(textToSearch)"
    }
    
    override func numberOfSections() -> Int {
        return AudioViewModel.Section.count.rawValue
    }
    
    override func numberOfRows(inSection section: Int) -> Int {
        if section < models.count {
            return models[section].count
        }
        return 0
    }
    
    override func model(forSection section: Int, row: Int) -> Any? {
        if section < models.count {
            let modelSection = models[section]
            if row < modelSection.count {
                return modelSection[row]
            }
        }
        return nil
    }
    
    override func heightForHeader(at section: Int) -> CGFloat {
        if section < models.count {
            let modelSection = models[section]
            if modelSection.count > 0 {
                return CGFloat(CatalogViewModel.cellheight)
            }
        }
        return 0
    }
    
    override func titleForHeader(inSection section: Int) -> String? {
        if section < models.count {
            let n = models[section].count
            if n == 0 {
                return nil
            }
            var str = [String]()
            str.append(models[section].first?.section ?? "")
            if n > 1 {
                str.append("\(n) audios")
            }
            else {
                str.append("Only one audio")
            }
            return str.joined(separator: ": ")
        }
        return nil
    }
    
    override func heightForRow(at section: Int, row: Int) -> CGFloat {
        if section < models.count {
            let modelSection = models[section]
            if row < modelSection.count {
                return CGFloat(AudioViewModel.cellheight)
            }
        }
        return 0
    }
    
    override func privateRefresh(isClean: Bool = false,
                                 prompt: String,
                                 startClosure: (() -> Void)? = nil,
                                 finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        
        models = [[AudioViewModel](), [AudioViewModel](), [AudioViewModel](), [AudioViewModel]()]

        if textToSearch.count == 0 {
            finishClosure?(nil)
            return
        }
        
        finishBlock = finishClosure
        
        startClosure?()
        
        RestApi.instance.context?.performAndWait {
            if let rnaStations = RNAStation.search(byName: textToSearch), rnaStations.count > 0 {
                let amModels = rnaStations.filter({ (station) -> Bool in
                    return station.amUri?.count ?? 0 > 0
                }).map({ AudioViewModel(stationAm: $0) })
                if amModels.count > 0 {
                    models[AudioViewModel.Section.model0.rawValue].append(contentsOf: amModels)
                }
                
                let fmModels = rnaStations.filter({ (station) -> Bool in
                    return station.fmUri?.count ?? 0 > 0
                }).map({ AudioViewModel(stationFm: $0) })
                
                if fmModels.count > 0 {
                    models[AudioViewModel.Section.model0.rawValue].append(contentsOf: amModels)
                }
            }
            
            if let streams = Stream.search(byName: textToSearch), streams.count > 0 {
                let streamModels = streams.map({ AudioViewModel(stream: $0) })
                if streamModels.count > 0 {
                    models[AudioViewModel.Section.model1.rawValue].append(contentsOf: streamModels)
                }
            }
        }
        
        let closure = {
            if let catalogs = RTCatalog.search(byName: self.textToSearch), catalogs.count > 0 {
                var audiosTmp = [AudioViewModel]()
                for element in catalogs {
                    if element.isAudio(), element.url?.count ?? 0 > 0 {
                        let viewModel = AudioViewModel(audio: element)
                        if audiosTmp.first(where: { (avm) -> Bool in
                            return avm.url == viewModel.url
                        }) == nil {
                            audiosTmp.append(viewModel)
                        }
                    }
                    else {
                        let catalogModel = CatalogViewModel(catalog: element)
                        for viewModel in catalogModel.audios {
                            if audiosTmp.first(where: { (avm) -> Bool in
                                return avm.url == viewModel.url
                            }) == nil {
                                audiosTmp.append(viewModel)
                            }
                        }
                    }
                }
                if audiosTmp.count > 0 {
                    self.models[AudioViewModel.Section.model2.rawValue].append(contentsOf: audiosTmp)
                }
            }
            
            if let bookmarks = Bookmark.search(byName: self.textToSearch), bookmarks.count > 0 {
                let bookmarkModels = bookmarks.map({ AudioViewModel(bookmark: $0) })
                if bookmarkModels.count > 0 {
                    self.models[AudioViewModel.Section.model3.rawValue].append(contentsOf: bookmarkModels)
                }
            }
            
            self.lastUpdated = Date()
            
            finishClosure?(nil)
        }
        
        if isClean {
            RadioTimeController.search(text: textToSearch, finishClosure: { (error) in
                RestApi.instance.context?.performAndWait {
                    closure()
                }
            })
        }
        else {
            closure()
        }
    }
}
