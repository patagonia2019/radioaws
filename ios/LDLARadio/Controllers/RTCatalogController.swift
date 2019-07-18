//
//  RTCatalogController.swift
//  LDLARadio
//
//  Created by fox on 13/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Foundation
import JFCore

class RTCatalogController {
    
    var mainCatalogViewModel : CatalogViewModel? = nil
    var catalogTableViewModel = CatalogTableViewModel.init()

    init() {
    }
    
    init(withCatalogViewModel catalogViewModel: CatalogViewModel?) {
        mainCatalogViewModel = catalogViewModel
    }
    
    func numberOfSections() -> Int {
        return catalogTableViewModel.sections.count
    }
    
    func titleForHeader(inSection section: Int) -> String? {
        return catalogTableViewModel.titleForHeader(inSection: section)
    }
    
    func numberOfRows(inSection section: Int) -> Int {
        return catalogTableViewModel.numberOfRows(inSection: section)
    }
    
    func catalog(forSection section: Int, row: Int) -> Any? {
        return catalogTableViewModel.elements(forSection: section, row: row)
    }
    
    func heightForRow(at section: Int, row: Int) -> CGFloat {
        return CGFloat(catalogTableViewModel.heightForRow(at: section, row: row))
    }
    
    func title() -> String {
        return catalogTableViewModel.title
    }
    
    func prompt() -> String {
        return catalogTableViewModel.prompt
    }
    
    func querySections(catalogSections: [RTCatalog]?, finishClosure: ((_ error: Error?) -> Void)? = nil) {
        var sectionsToPop = [RTCatalog]()
        if let catalogSections = catalogSections {
            sectionsToPop.append(contentsOf: catalogSections)
        }
        if catalogSections?.count == 0 {
            finishClosure?(nil)
            return
        }
        
        let mainSection = sectionsToPop.popLast()
        
        if let mainCatalog = mainCatalogFromDb(mainCatalog: mainSection),
            mainCatalog.sections?.count ?? 0 > 0 {
            if sectionsToPop.count > 0 {
                self.querySections(catalogSections: sectionsToPop, finishClosure: finishClosure)
            }
            else {
                finishClosure?(nil)
            }
            return
        }
        if let sectionUrl = mainSection?.url, (mainSection?.isLink() ?? false) {
            RTCatalogManager.instance.setup(url: sectionUrl) { error, catalog in
                
                if error != nil {
                    finishClosure?(error)
                    return
                }
                catalog?.url = sectionUrl
                
                let audios = mainSection?.audios
                let sections = mainSection?.sections
                let title = mainSection?.title ?? mainSection?.text
                let sectionCatalog = mainSection?.sectionCatalog
                mainSection?.remove()
                catalog?.sectionCatalog = sectionCatalog
                if catalog?.title == nil {
                    catalog?.title = title
                }
                if catalog?.sections?.count ?? 0 > 0 {
                    if let sections = sections?.array as? [RTCatalog] {
                        for section in sections {
                            section.sectionCatalog = catalog
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
                
                if sectionsToPop.count > 0 {
                    self.querySections(catalogSections: sectionsToPop, finishClosure: finishClosure)
                }
                else {
                    finishClosure?(error)
                }
            }
        }
    }
    
    func refresh(isClean: Bool = false,
                 prompt: String = "Radio Time",
                 startClosure: (() -> Void)? = nil,
                 finishClosure: ((_ error: Error?) -> Void)? = nil) {

        startClosure?()

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

                if false /* catalogSections.count > 0 */ {
                    self.querySections(catalogSections: catalogSections, finishClosure: { (error) in
                        self.mainCatalogViewModel = CatalogViewModel(catalog: mainCatalog)
                        if let mainCatalogViewModel = self.mainCatalogViewModel {
                            self.catalogTableViewModel = CatalogTableViewModel(catalog: mainCatalogViewModel, parentTitle: mainCatalog?.sectionCatalog?.title ?? prompt)
                        }
                        finishClosure?(nil)
                    })
                }
                else {
                    mainCatalogViewModel = CatalogViewModel(catalog: mainCatalog)
                    if let mainCatalogViewModel = mainCatalogViewModel {
                        catalogTableViewModel = CatalogTableViewModel(catalog: mainCatalogViewModel, parentTitle: mainCatalog?.sectionCatalog?.title ?? prompt)
                    }
                    finishClosure?(nil)
                }
                return
            }
        }
        
        RTCatalogManager.instance.setup(url: mainCatalog?.url ?? self.mainCatalogViewModel?.urlString()) { error, catalog in
            DispatchQueue.main.async {

                if error != nil {
                    finishClosure?(error)
                    return
                }
                
                if (self.mainCatalogViewModel == nil || self.mainCatalogViewModel?.title == "Browse") && catalog?.title == "Browse" {
                    catalog?.url = RestApi.Constants.Service.rtServer
                }
                else {
                    catalog?.url = mainCatalog?.url ?? self.mainCatalogViewModel?.urlString()
                }
//                let audios = mainCatalog?.audios
                let sections = mainCatalog?.sections
                let title = mainCatalog?.title ?? mainCatalog?.text
                let sectionCatalog = mainCatalog?.sectionCatalog
                mainCatalog?.remove()
                catalog?.sectionCatalog = sectionCatalog
                
                
                if catalog?.title == nil {
                    catalog?.title = title
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
//                if catalog?.audios?.count ?? 0 > 0 {
//                    if let audios = audios?.array as? [RTCatalog] {
//                        for audio in audios {
//                            audio.audioCatalog = catalog
//                        }
//                    }
//                }
                
                if false /* catalogSections.count > 0 */ {
                    self.querySections(catalogSections: catalogSections, finishClosure: { (error) in
                        CoreDataManager.instance.save()
                        self.mainCatalogViewModel = CatalogViewModel(catalog: catalog)
                        if let mcvm = self.mainCatalogViewModel {
                            self.catalogTableViewModel = CatalogTableViewModel(catalog: mcvm, parentTitle: catalog?.sectionCatalog?.title ?? prompt)
                            
                        }
                        finishClosure?(error)
                    })
                }
                else {
                    CoreDataManager.instance.save()
                    self.mainCatalogViewModel = CatalogViewModel(catalog: catalog)
                    if let mcvm = self.mainCatalogViewModel {
                        self.catalogTableViewModel = CatalogTableViewModel(catalog: mcvm, parentTitle: catalog?.sectionCatalog?.title ?? prompt)
                    }                    
                    finishClosure?(error)
                }
            }
        }
    }

    func mainCatalogFromDb(mainCVM: CatalogViewModel?) -> RTCatalog? {
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

    func mainCatalogFromDb(mainCatalog: RTCatalog?) -> RTCatalog? {
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
