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
struct CatalogViewModel {
    
    /// Some constants hardcoded here
    public struct hardcode {
        static let cellheight: Float = UIScreen.main.traitCollection.userInterfaceIdiom == .pad ? 60 : 44
    }
    
    private var icon: Commons.symbols.FontAwesome = .indent
    private var url: URL? = nil
    var detail: String
    let iconColor: UIColor = .darkGray
    let textColor: UIColor = .black
    var selectionStyle: UITableViewCell.SelectionStyle = .blue
    let font: UIFont? = UIFont(name: Commons.font.name, size: Commons.font.size.XL)
    var accessoryType : UITableViewCell.AccessoryType = .disclosureIndicator
    var title: String
    var tree: String
    var sections = [CatalogViewModel]()
    var audios = [AudioViewModel]()
    var isExpanded : Bool = false
    var isBookmarked: Bool? = nil

    init() {
        title = "No more info"
        tree = "?"
        icon = .ban
        detail = "No more detail"
        selectionStyle = .none
        accessoryType = .none
    }

    init(catalog: RTCatalog?) {
        title = catalog?.titleOrText() ?? "No more info"
        tree = catalog?.titleTree() ?? "?"
        isExpanded = catalog?.isExpanded ?? false
        
        detail = (catalog?.isOnlyText() ?? false) ? (catalog?.text ?? catalog?.subtext ?? "No more detail") : "No more detail"
        if let queryUrl = catalog?.url,
            let urlChecked = URL(string: queryUrl),
            UIApplication.shared.canOpenURL(urlChecked) {
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
            if element.image?.count ?? 0 > 0, element.url?.count ?? 0 > 0 {
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
                return c1.title < c2.title
            })
            audios = audiosTmp.sorted(by: { (c1, c2) -> Bool in
                return c1.title < c2.title
            })
        }
        
//        if sections.count == 0 && audios.count == 0 && urlString() == nil {
//            sections.append(CatalogViewModel())
//        }
        isBookmarked = checkIfBookmarked()

    }
    
    init(desconcierto: Desconcierto?, isAlreadyExpanded: Bool = false) {
        title = desconcierto?.date ?? ""
        tree = ""
        detail = ""
        let queryUrl = "\(RestApi.Constants.Service.ldlaServer)/desconciertos/\(desconcierto?.id ?? 0).json"
        if let urlChecked = URL(string: queryUrl),
            UIApplication.shared.canOpenURL(urlChecked) {
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
        title = bookmark?.subTitle ?? ""
        tree = bookmark?.title ?? ""
        detail = bookmark?.detail ?? ""
        if let catalogUrl = bookmark?.url,
            let urlChecked = URL(string: catalogUrl),
            UIApplication.shared.canOpenURL(urlChecked) {
            url = urlChecked
        }
        isBookmarked = true
    }

    /// to know if the model is in bookmark
    func checkIfBookmarked() -> Bool? {
        if audios.count > 0 {
            return audios.filter({ (audio) -> Bool in
                return audio.isBookmarked
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
