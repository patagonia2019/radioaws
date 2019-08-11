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
    
    let cloudKit: CloudKitManager = CloudKitManager.instance

    private var models = [[AudioViewModel](), [AudioViewModel](), [AudioViewModel](), [AudioViewModel]()]

    override var useRefresh : Bool {
        return true
    }

    override init() {
        super.init()
    }
    
    override func prompt() -> String {
        return "Bookmarks"
    }
    
    private func count() -> Int {
        var count : Int = 0
        for n in 0..<AudioViewModel.Section.count.rawValue {
            count += models[n].count
        }
        return count
    }

    override func numberOfSections() -> Int {
        return count() > 0 ? AudioViewModel.Section.count.rawValue : 1
    }
    
    override func numberOfRows(inSection section: Int) -> Int {
        if count() == 0 && section == 0 {
            return 1
        }
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
        if count() == 0 {
            if section == 0 {
                return CGFloat(CatalogViewModel.cellheight)
            }
            else {
                return 0
            }
        }
        if section < models.count {
            let modelSection = models[section]
            if modelSection.count > 0 {
                return CGFloat(CatalogViewModel.cellheight)
            }
        }
        return 0
    }

    override func titleForHeader(inSection section: Int) -> String? {
        if count() == 0 && section == 0 {
            return "No bookmarks"
        }
        if section < models.count {
            let n = models[section].count
            if n == 0 {
                return nil
            }
            var str = [String]()
            str.append(models[section].first?.section ?? "")
            if n > 1 {
                str.append("\(n) Items")
            }
            else {
                str.append("1 Item")
            }
            return str.joined(separator: ": ")
        }
        return nil
    }
    
    override func heightForRow(at section: Int, row: Int) -> CGFloat {
        if count() == 0 && section == 0 {
            if let model = model(forSection: section, row: row) as? AudioViewModel {
                return CGFloat(model.height())
            }
        }
        if section < models.count {
            let modelSection = models[section]
            if row < modelSection.count {
                if let model = model(forSection: section, row: row) as? AudioViewModel {
                    return CGFloat(model.height())
                }
            }
        }
        return 0
    }
    
    override func privateRefresh(isClean: Bool = false,
                                 prompt: String,
                                 finishClosure: ((_ error: JFError?) -> Void)? = nil) {
        
        let closure = {
          
            self.models = [[AudioViewModel](), [AudioViewModel](), [AudioViewModel](), [AudioViewModel]()]
            
            
            RestApi.instance.context?.performAndWait {
                let all = Bookmark.all()
                
                if let suggestions = all?.filter({ (bookmark) -> Bool in
                    return bookmark.section == AudioViewModel.ControllerName.suggestion.rawValue
                }), suggestions.count > 0 {
                    let sugModels = suggestions.map({ AudioViewModel(bookmark: $0) })
                    if sugModels.count > 0 {
                        self.models[AudioViewModel.Section.model0.rawValue].append(contentsOf: sugModels)
                    }
                }
                
                if let rnas = all?.filter({ (bookmark) -> Bool in
                    return bookmark.section == AudioViewModel.ControllerName.rna.rawValue
                }), rnas.count > 0 {
                    let rnaModels = rnas.map({ AudioViewModel(bookmark: $0) })
                    if rnaModels.count > 0 {
                        self.models[AudioViewModel.Section.model1.rawValue].append(contentsOf: rnaModels)
                    }
                }
                
                if let rts = all?.filter({ (bookmark) -> Bool in
                    return bookmark.section == AudioViewModel.ControllerName.radioTime.rawValue
                }), rts.count > 0 {
                    let rtsModels = rts.map({ AudioViewModel(bookmark: $0) })
                    if rtsModels.count > 0 {
                        self.models[AudioViewModel.Section.model2.rawValue].append(contentsOf: rtsModels)
                    }
                }
                
                if let eds = all?.filter({ (bookmark) -> Bool in
                    return bookmark.section == AudioViewModel.ControllerName.desconcierto.rawValue
                }), eds.count > 0 {
                    let edsModels = eds.map({ AudioViewModel(bookmark: $0) })
                    if edsModels.count > 0 {
                        self.models[AudioViewModel.Section.model3.rawValue].append(contentsOf: edsModels)
                    }
                }
                finishClosure?(nil)
            }
        }
       
        if isClean {
            
            RestApi.instance.context?.performAndWait {
                Bookmark.clean()
                cloudKit.refresh { (error) in
                    if error != nil {
                        CoreDataManager.instance.rollback()
                    } else {
                        CoreDataManager.instance.save()
                    }
                    closure()
                }
            }
        }
        else {
            closure()
        }
    }
}


