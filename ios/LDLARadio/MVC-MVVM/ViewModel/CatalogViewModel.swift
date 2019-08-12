//
//  CatalogViewModel.swift
//  LDLARadio
//
//  Created by fox on 13/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

// This view model will be responsible of render out information in the views for Catalog info
struct CatalogViewModel : BaseViewModelProtocol {
    
    let icon: Commons.symbols.FontAwesome = .indent
    let iconColor = UIColor.darkGray

    var url: URL? = nil
    static let cellheight : Float = UIScreen.main.traitCollection.userInterfaceIdiom == .pad ? 60 : 44

    var selectionStyle = UITableViewCell.SelectionStyle.blue
    var accessoryType = UITableViewCell.AccessoryType.disclosureIndicator

    var detail : LabelViewModel = LabelViewModel(text: "No more detail", color: .green, font: UIFont(name: Commons.font.name, size: Commons.font.size.S), isHidden: true, lines: 1)

    var isBookmarked: Bool? = nil
    var title : LabelViewModel = LabelViewModel(text: "No more info", color: .blue, font: UIFont(name: Commons.font.name, size: Commons.font.size.XL), isHidden: true, lines: 1)

    var tree: String = ""

    var sections = [CatalogViewModel]()
    var audios = [AudioViewModel]()

    var isExpanded : Bool? = nil
    
    var section : String = ""

    init() {
        title.text = "No more info"
        tree = "?"
        detail.text = "No more detail"
        selectionStyle = .none
        accessoryType = .none
    }

    init(catalog: RTCatalog?) {
        section = AudioViewModel.ControllerName.radioTime.rawValue
        title.text = catalog?.titleAndText() ?? "No more info"
        tree = catalog?.titleTree() ?? "?"
        isExpanded = catalog?.isExpanded
        
        if let catalog = catalog,
            let text = catalog.text ?? catalog.subtext {
            detail.text = catalog.isOnlyText() ? text : ""
        }
        if let queryUrl = catalog?.url,
            let urlChecked = URL(string: queryUrl) {
            url = urlChecked
        }
        var all = [RTCatalog]()
        if let sectionsOfCatalog = catalog?.sections?.array as? [RTCatalog] {
            all.append(contentsOf: sectionsOfCatalog)
        }
        if let audiosOfCatalog = catalog?.audios?.array as? [RTCatalog] {
            all.append(contentsOf: audiosOfCatalog)
        }
        var sectionsTmp = [CatalogViewModel]()
        var audiosTmp = [AudioViewModel]()
        
        for element in all {
            if element.isAudio(), element.url?.count ?? 0 > 0 {
                if element.audioCatalog == nil {
                    if element.sectionCatalog == nil {
                        element.audioCatalog = catalog
                    }
                    else {
                        element.audioCatalog = element.sectionCatalog
                        element.sectionCatalog = nil
                    }
                }
                let viewModel = AudioViewModel(audio: element)
                audiosTmp.append(viewModel)
            }
            else {
                if element.sectionCatalog == nil {
                    if element.audioCatalog == nil {
                        element.sectionCatalog = catalog
                    }
                    else {
                        element.sectionCatalog = element.audioCatalog
                        element.audioCatalog = nil
                    }
                }
                let viewModel = CatalogViewModel(catalog: element)
                sectionsTmp.append(viewModel)
            }
            sections = sectionsTmp.sorted(by: { (c1, c2) -> Bool in
                return c1.title.text < c2.title.text
            })
            audios = audiosTmp.sorted(by: { (c1, c2) -> Bool in
                return c1.title.text < c2.title.text
            })
        }
        
        isBookmarked = checkIfBookmarked()
        
    }

    init(archiveCollection: ArchiveCollection?, isAlreadyExpanded: Bool = false) {
        section = AudioViewModel.ControllerName.archiveOrg.rawValue
        title.text = archiveCollection?.title ?? ""
        tree = ""
        detail.text = archiveCollection?.detail ?? ""
        
        if let queryUrl = archiveCollection?.urlString(),
            let urlChecked = URL(string: queryUrl) {
            url = urlChecked
        }
        
        let meta = archiveCollection?.meta
        let response = meta?.response
        if let docs = response?.docs {
            sections = docs.map({ CatalogViewModel(archiveDoc: $0 as? ArchiveDoc, isAlreadyExpanded: isAlreadyExpanded) })
        }
        
        isBookmarked = checkIfBookmarked()
        isExpanded = isAlreadyExpanded
    }

    init(archiveDoc: ArchiveDoc?, isAlreadyExpanded: Bool = false) {
        section = AudioViewModel.ControllerName.archiveOrg.rawValue
        title.text = archiveDoc?.title ?? ""
        tree = archiveDoc?.subjectString() ?? ""
        detail.text = archiveDoc?.descript ?? ""
        
        if let queryUrl = archiveDoc?.urlString(),
            let urlChecked = URL(string: queryUrl) {
            url = urlChecked
        }
        
        isBookmarked = checkIfBookmarked()
        isExpanded = isAlreadyExpanded
    }
    
    init(desconcierto: Desconcierto?, isAlreadyExpanded: Bool = false) {
        section = AudioViewModel.ControllerName.desconcierto.rawValue
        title.text = desconcierto?.date ?? ""
        tree = ""
        detail.text = ""
        let queryUrl = "\(RestApi.Constants.Service.ldlaServer)/desconciertos/\(desconcierto?.id ?? 0).json"
        if let urlChecked = URL(string: queryUrl) {
            url = urlChecked
        }
        var order : Int = 0
        for streamUrl in [desconcierto?.streamUrl1, desconcierto?.streamUrl2, desconcierto?.streamUrl3] {
            order = order + 1
            let audio = AudioViewModel(desconcierto: desconcierto, audioUrl: streamUrl, order: order)
            if audio.url?.absoluteString.count ?? 0 > 0 {
                audios.append(audio)
            }
        }
        isBookmarked = checkIfBookmarked()
        isExpanded = isAlreadyExpanded
    }
    
    /// initialization of the view model for bookmarked audios
    init(bookmark: Bookmark?) {
        section = bookmark?.section ?? AudioViewModel.ControllerName.bookmark.rawValue
        title.text = bookmark?.subTitle ?? ""
        tree = bookmark?.title ?? ""
        detail.text = bookmark?.detail ?? ""
        if let catalogUrl = bookmark?.url,
            let urlChecked = URL(string: catalogUrl) {
            url = urlChecked
        }
        isBookmarked = true
    }

    /// to know if the model is in bookmark
    func checkIfBookmarked() -> Bool? {
        if audios.count > 0 {
            return audios.filter({ (audio) -> Bool in
                return audio.isBookmarked ?? false
            }).count == audios.count
        }
        else {
            return nil
        }
    }

    func iconText() -> String {
        return "\(Commons.symbols.showAwesome(icon: icon))"
    }
    
    func urlString() -> String? {
        return url?.absoluteString
    }
}
