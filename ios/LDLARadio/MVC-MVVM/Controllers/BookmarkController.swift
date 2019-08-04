//
//  BookmarkController.swift
//  LDLARadio
//
//  Created by fox on 24/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import JFCore


class BookmarkController: BaseController {
    
    /// Notification for when bookmark has changed.
    static let didRefreshNotification = NSNotification.Name(rawValue: "BookmarkController.didRefreshNotification")
        
    var models = [[AudioViewModel](), [AudioViewModel](), [AudioViewModel](), [AudioViewModel]()]

    override var useRefresh : Bool {
        return false
    }

    override init() {
    }
    
    override func prompt() -> String {
        return "Bookmarks"
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
        if section < models.count, models[section].count > 0 {
            return CGFloat(CatalogViewModel.cellheight)
        }
        return 0
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

    override func privateRefresh(isClean: Bool = false,
                                 prompt: String,
                                 startClosure: (() -> Void)? = nil,
                                 finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        
        models = [[AudioViewModel](), [AudioViewModel](), [AudioViewModel](), [AudioViewModel]()]

        finishBlock = finishClosure
        
        startClosure?()
        
        RestApi.instance.context?.performAndWait {
            let all = Bookmark.all()
            
            if let suggestions = all?.filter({ (bookmark) -> Bool in
                return bookmark.section == AudioViewModel.ControllerName.suggestion.rawValue
            }), suggestions.count > 0 {
                let sugModels = suggestions.map({ AudioViewModel(bookmark: $0) })
                if sugModels.count > 0 {
                    models[AudioViewModel.Section.model0.rawValue].append(contentsOf: sugModels)
                }
            }

            if let rnas = all?.filter({ (bookmark) -> Bool in
                return bookmark.section == AudioViewModel.ControllerName.rna.rawValue
            }), rnas.count > 0 {
                let rnaModels = rnas.map({ AudioViewModel(bookmark: $0) })
                if rnaModels.count > 0 {
                    models[AudioViewModel.Section.model1.rawValue].append(contentsOf: rnaModels)
                }
            }

            if let rts = all?.filter({ (bookmark) -> Bool in
                return bookmark.section == AudioViewModel.ControllerName.radioTime.rawValue
            }), rts.count > 0 {
                let rtsModels = rts.map({ AudioViewModel(bookmark: $0) })
                if rtsModels.count > 0 {
                    models[AudioViewModel.Section.model2.rawValue].append(contentsOf: rtsModels)
                }
            }

            if let eds = all?.filter({ (bookmark) -> Bool in
                return bookmark.section == AudioViewModel.ControllerName.desconcierto.rawValue
            }), eds.count > 0 {
                let edsModels = eds.map({ AudioViewModel(bookmark: $0) })
                if edsModels.count > 0 {
                    models[AudioViewModel.Section.model3.rawValue].append(contentsOf: edsModels)
                }
            }
            finishClosure?(nil)
        }
    }

}
