//
//  CatalogViewModel.swift
//  LDLARadio
//
//  Created by fox on 13/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

// This view model will be responsible of render out information in the views for Catalog info
struct CatalogViewModel {
    
    /// Some constants hardcoded here
    public struct hardcode {
        static let cellheight: Float = 44
        static let identifier: String = "CatalogIdentifier"
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
        
        detail = (catalog?.isOnlyText() ?? false) ? (catalog?.text ?? catalog?.subtext ?? "No more detail") : "No more detail"
        if let queryUrl = catalog?.url,
            let urlChecked = URL(string: queryUrl),
            UIApplication.shared.canOpenURL(urlChecked) {
            url = urlChecked
        }
        else {
            print("here")
        }
        let sortBy = [NSSortDescriptor(key: "text", ascending: true)]
        if let innerSections = catalog?.sections?.sortedArray(using: sortBy) as? [RTCatalog] {
            for section in innerSections {
                if section.isLink() {
                    let viewModel = CatalogViewModel(catalog: section)
                    sections.append(viewModel)
                }
                else if section.isAudio(), section.url?.count ?? 0 > 0 {
                    section.audioCatalog = section.sectionCatalog
                    let viewModel = AudioViewModel(audio: section)
                    audios.append(viewModel)
                }
                else if section.isOnlyText() && section.title?.count ?? 0 > 0 {
                    let viewModel = CatalogViewModel(catalog: section)
                    sections.append(viewModel)
                }
            }
        }

        if let innerAudios = catalog?.audios?.sortedArray(using: sortBy) as? [RTCatalog] {
            for audio in innerAudios {
                if audio.isLink() {
                    audio.sectionCatalog = audio.audioCatalog
                    let viewModel = CatalogViewModel(catalog: audio)
                    sections.append(viewModel)
                }
                else if audio.isAudio(), audio.url?.count ?? 0 > 0 {
                    let viewModel = AudioViewModel(audio: audio)
                    audios.append(viewModel)
                }
                else if audio.isOnlyText() && audio.title?.count ?? 0 > 0 {
                    let viewModel = CatalogViewModel(catalog: audio)
                    sections.append(viewModel)
                }
            }
        }
        
        if sections.count == 0 && audios.count == 0 && urlString() == nil {
            sections.append(CatalogViewModel())
        }
    }
    
    func iconText() -> String {
        return "\(Commons.symbols.showAwesome(icon: icon))"
    }
    
    func urlString() -> String? {
        return url?.absoluteString
    }
        
}
