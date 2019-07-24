//
//  CatalogTableViewModel.swift
//  LDLARadio
//
//  Created by fox on 17/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Foundation

struct CatalogTableViewModel {
    var title : String = ""
    var prompt : String = ""
    var sections = [String]()
    var elements = [String:[Any]]()
    var defaultElements = [String:[Any]]()
    var heights = [String:[NSNumber]]()

    init() {
    }

    init(catalog: CatalogViewModel, parentTitle: String? = "Radio Time") {
        prompt = catalog.tree
        title = parentTitle ?? "Radio Time"
        for section in catalog.sections.sorted(by: { (c1, c2) -> Bool in
            return c1.title <= c2.title
        }) {
            sections.append(section.title)
            
            var sectionDefault = defaultElements[section.title] ?? [Any]()
            var sectionElements = elements[section.title] ?? [Any]()
            var heightElements = heights[section.title] ?? [NSNumber]()
            if section.sections.count > 0 {
                if section.sections.count == 1 {
                    print("here")
                    title = "\(title) - \(section.title)"
                    if let subSections = section.sections.first?.sections {
                        sectionElements.append(contentsOf: subSections)
                        for _ in subSections {
                            heightElements.append(NSNumber(value: CatalogViewModel.hardcode.cellheight))
                        }
                    }
                    if let audios = section.sections.first?.audios {
                        sectionElements.append(contentsOf: audios)
                        for _ in audios {
                            heightElements.append(NSNumber(value: AudioViewModel.hardcode.cellheight))
                        }
                    }
                    heights[section.title] = heightElements
               }
                else {
                    sectionElements.append(contentsOf: section.sections)
                    for _ in section.sections {
                        heightElements.append(NSNumber(value: CatalogViewModel.hardcode.cellheight))
                    }
                    heights[section.title] = heightElements
                }
            }
            if section.audios.count > 0 {
                sectionElements.append(contentsOf: section.audios)
                for _ in section.audios {
                    heightElements.append(NSNumber(value: AudioViewModel.hardcode.cellheight))
                }
            }
            if sectionElements.count == 0 {
                sectionDefault.append(section)
                heightElements.append(NSNumber(value: CatalogViewModel.hardcode.cellheight))
            }
            elements[section.title] = sectionElements
            heights[section.title] = heightElements
            defaultElements[section.title] = sectionDefault
        }
        if catalog.audios.count > 0 {
            sections.append(catalog.title)

            var audioElements = elements[catalog.title] ?? [Any]()
            audioElements.append(contentsOf: catalog.audios)
            var heightElements = heights[catalog.title] ?? [NSNumber]()
            for _ in catalog.audios {
                heightElements.append(NSNumber(value: AudioViewModel.hardcode.cellheight))
            }
            elements[catalog.title] = audioElements
            heights[catalog.title] = heightElements
        }
        if elements.count == 0 {
            sections.append(catalog.title)
            var sectionDefault = defaultElements[title] ?? [Any]()
            sectionDefault.append(CatalogViewModel())
            defaultElements[title] = sectionDefault
            var heightElements = heights[catalog.title] ?? [NSNumber]()
            heightElements.append(NSNumber(value: CatalogViewModel.hardcode.cellheight))
            heights[catalog.title] = heightElements
        }
    }
    
    func titleForHeader(inSection section: Int) -> String {
        if section < sections.count {
            return sections[section]
        }
        return ""
    }
    
    func numberOfRows(inSection section: Int) -> Int {
        if section < sections.count {
            let sectionName = sections[section]
            let count = elements[sectionName]?.count ?? 0
            if count > 0 {
                return count
            }
        }
        return 1
    }
    
    func elements(forSection section: Int, row: Int) -> Any? {
        
        if section < sections.count {
            let sectionName = sections[section]
            if let objects = elements[sectionName] {
                if row < objects.count {
                    return objects[row]
                }
            }
            return defaultElements[sectionName]?.first
        }
        return nil
    }
 
    func heightForRow(at section: Int, row: Int) -> Float {
        if section < sections.count {
            let sectionName = sections[section]
            if let objects = heights[sectionName] {
                if row < objects.count {
                    return objects[row].floatValue
                }
            }
        }
        return CatalogViewModel.hardcode.cellheight
    }
    
}
