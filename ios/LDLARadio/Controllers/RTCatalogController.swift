//
//  RTCatalogController.swift
//  LDLARadio
//
//  Created by fox on 13/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Foundation
import JFCore

class RTCatalogController: BaseController {
    
    var mainCatalogViewModel : CatalogViewModel? = nil
    var catalogTableViewModel = CatalogTableViewModel.init()

    override init() { }

    init(withCatalogViewModel catalogViewModel: CatalogViewModel?) {
        mainCatalogViewModel = catalogViewModel
    }
    
    override func numberOfSections() -> Int {
        return catalogTableViewModel.sections.count == 0 ? 1 : catalogTableViewModel.sections.count
    }
    
    override func titleForHeader(inSection section: Int) -> String? {
        return catalogTableViewModel.titleForHeader(inSection: section)
    }
    
    override func numberOfRows(inSection section: Int) -> Int {
        return catalogTableViewModel.numberOfRows(inSection: section)
    }
    
    override func catalog(forSection section: Int, row: Int) -> Any? {
        return catalogTableViewModel.elements(forSection: section, row: row)
    }
    
    override func heightForRow(at section: Int, row: Int) -> CGFloat {
        return CGFloat(catalogTableViewModel.heightForRow(at: section, row: row))
    }
    
    override func title() -> String {
        var str = [String]()
        str.append(catalogTableViewModel.title + ". ")
        str.append(super.title())
        return str.joined()
    }
    
    override func prompt() -> String {
        return catalogTableViewModel.prompt
    }
        
    override func privateRefresh(isClean: Bool = false,
                 prompt: String,
                 startClosure: (() -> Void)? = nil,
                 finishClosure: ((_ error: Error?) -> Void)? = nil) {

        let mainCatalog = mainCatalogFromDb(mainCVM: mainCatalogViewModel)

        var resetInfo = false
        if isClean {
            if (self.mainCatalogViewModel == nil || self.mainCatalogViewModel?.title == "Browse") && mainCatalog?.title == "Browse" {
                resetInfo = true
            }
            else if (mainCatalog?.url ?? self.mainCatalogViewModel?.urlString()) != nil {
                resetInfo = true
            }
        }
    

        if resetInfo == false {
            if mainCatalogViewModel?.audios.count ?? 0 > 0 {
                if let mainCatalogViewModel = mainCatalogViewModel {
                    catalogTableViewModel = CatalogTableViewModel(catalog: mainCatalogViewModel, parentTitle: mainCatalog?.sectionCatalog?.title ?? prompt)
                }
                lastUpdated = mainCatalog?.updatedAt
                finishClosure?(nil)
                return
            }

            if  mainCatalog != nil &&
                (mainCatalog?.sections?.count ?? 0 > 0 || mainCatalog?.audios?.count ?? 0 > 0)  {
                var catalogSections = [RTCatalog]()
                if let innerSections = mainCatalog?.sections?.array as? [RTCatalog] {
                    for section in innerSections {
                        if let mainSection = mainCatalogFromDb(mainCatalog: section),
                            mainSection.sections?.count ?? 0 > 0 {
                        }
                        else if section.url?.count ?? 0 > 0 {
                            catalogSections.append(section)
                        }
                    }
                }

                mainCatalogViewModel = CatalogViewModel(catalog: mainCatalog)
                if let mainCatalogViewModel = mainCatalogViewModel {
                    catalogTableViewModel = CatalogTableViewModel(catalog: mainCatalogViewModel, parentTitle: mainCatalog?.sectionCatalog?.title ?? prompt)
                }
                lastUpdated = mainCatalog?.updatedAt
                finishClosure?(nil)
                return
            }
        }
        let url = mainCatalog?.url ?? mainCatalogViewModel?.urlString()
        if url == nil && (mainCatalogViewModel != nil && mainCatalogViewModel?.title != "Browse") {
            finishClosure?(nil)
            return
        }
        RTCatalogManager.instance.setup(url: url) { error, catalog in

            if error != nil {
                DispatchQueue.main.async {
                    self.lastUpdated = nil
                    finishClosure?(error)
                }
                return
            }
            
            if (self.mainCatalogViewModel == nil || self.mainCatalogViewModel?.title == "Browse") && catalog?.title == "Browse" {
                catalog?.url = RestApi.Constants.Service.rtServer
            }
            else {
                catalog?.url = mainCatalog?.url ?? self.mainCatalogViewModel?.urlString()
            }
            let audios = mainCatalog?.audios
            let sections = mainCatalog?.sections
            let title = mainCatalog?.title
            let text = mainCatalog?.text
            let sectionCatalog = mainCatalog?.sectionCatalog
            mainCatalog?.remove()
            catalog?.sectionCatalog = sectionCatalog
            
            
            if title != nil && catalog?.title == nil {
                catalog?.title = title
            }
            if text != nil && catalog?.text == nil {
                catalog?.text = text
            }
            
            var catalogSections = [RTCatalog]()
            
            if catalog?.sections?.count ?? 0 > 0 {
                if let sections = sections?.array as? [RTCatalog] {
                    for section in sections {
                        section.sectionCatalog = catalog
                    }
                }
                if let innerSections = catalog?.sections?.array as? [RTCatalog] {
                    
                    for section in innerSections {
                        if let mainSection = self.mainCatalogFromDb(mainCatalog: section),
                            mainSection.sections?.count ?? 0 > 0 {
                        }
                        else if section.url?.count ?? 0 > 0 {
                            catalogSections.append(section)
                        }
                    }
                    
                }
            }
            if catalog?.audios?.count ?? 0 > 0 {
                if let audios = audios?.array as? [RTCatalog] {
                    for audio in audios {
                        audio.audioCatalog = catalog
                    }
                }
            }
            
            CoreDataManager.instance.save()
            self.mainCatalogViewModel = CatalogViewModel(catalog: catalog)
            if let mcvm = self.mainCatalogViewModel {
                self.catalogTableViewModel = CatalogTableViewModel(catalog: mcvm, parentTitle: catalog?.sectionCatalog?.title ?? prompt)
            }
            self.lastUpdated = catalog?.updatedAt
            DispatchQueue.main.async {
                finishClosure?(error)
            }
        }
    }

    private func mainCatalogFromDb(mainCVM: CatalogViewModel?) -> RTCatalog? {
        if mainCVM == nil || mainCVM?.title == "Browse" {
            let catalog = RTCatalog.fetch(title: "Browse")?.first(where: { (catalog) -> Bool in
                return catalog.sections?.count ?? 0 > 0
            })
            if catalog?.url == nil {
                catalog?.url = RestApi.Constants.Service.rtServer
            }
            return catalog
        }
        if let urlString = mainCVM?.urlString() {
            return RTCatalog.fetch(url: urlString)?.first
        }
        if let section = mainCVM?.sections.first(where: { (section) -> Bool in
            return section.urlString()?.count ?? 0 > 0}),
            let urlString = section.urlString(),
            let superCatalog = RTCatalog.fetch(url: urlString)?.first,
            (superCatalog.audioCatalog != nil || superCatalog.sectionCatalog != nil) {
            
            return superCatalog.audioCatalog ?? superCatalog.sectionCatalog
        }
        else if let section = mainCVM?.audios.first(where: { (section) -> Bool in
            return section.urlString()?.count ?? 0 > 0}),
            let urlString = section.urlString(),
            let superCatalog = RTCatalog.fetch(url: urlString)?.first,
            (superCatalog.audioCatalog != nil || superCatalog.sectionCatalog != nil) {
            
            return superCatalog.audioCatalog ?? superCatalog.sectionCatalog
        }
        return nil
    }

    private func mainCatalogFromDb(mainCatalog: RTCatalog?) -> RTCatalog? {
        if let urlString = mainCatalog?.url {
            return RTCatalog.fetch(url: urlString)?.first
        }
        if let section = mainCatalog?.sections?.first(where: { (section) -> Bool in
            return (section as? RTCatalog)?.url?.count ?? 0 > 0}),
            let urlString = (section as? RTCatalog)?.url,
            let superCatalog = RTCatalog.fetch(url: urlString)?.first,
            (superCatalog.audioCatalog != nil || superCatalog.sectionCatalog != nil) {
        
            return superCatalog.audioCatalog ?? superCatalog.sectionCatalog
        }
        else if let section = mainCatalog?.audios?.first(where: { (section) -> Bool in
            return (section as? RTCatalog)?.url?.count ?? 0 > 0}),
            let urlString = (section as? RTCatalog)?.url,
            let superCatalog = RTCatalog.fetch(url: urlString)?.first,
            (superCatalog.audioCatalog != nil || superCatalog.sectionCatalog != nil) {
            return superCatalog.audioCatalog ?? superCatalog.sectionCatalog
        }
        return nil
    }
}
