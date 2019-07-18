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
        static let cellheight: CGFloat = 70
        static let identifier: String = "CatalogIdentifier"
    }
    
    private var icon: Commons.symbols.FontAwesome = .indent
    private var url: URL? = nil
    var detail: String
    let height: CGFloat = hardcode.cellheight
    let color: UIColor = .black
    let selectionStyle: UITableViewCell.SelectionStyle = .blue
    let font: UIFont? = UIFont(name: Commons.font.name, size: Commons.font.size)
    var accessoryType : UITableViewCell.AccessoryType = .none
    var title: String
    var sections = [CatalogViewModel]()
    var audios = [AudioViewModel]()

    init(catalog: RTCatalog?) {
        assert(catalog?.isLink() ?? false)
        title = catalog?.title ?? catalog?.text ?? ""
        detail = ""
        if let queryUrl = catalog?.url,
            let urlChecked = URL(string: queryUrl)/*,
            UIApplication.shared.canOpenURL(urlChecked)*/ {
            url = urlChecked
            accessoryType = .disclosureIndicator
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
                    accessoryType = .disclosureIndicator
                }
                else if section.isAudio() {
                    section.audioCatalog = section.sectionCatalog
                    let viewModel = AudioViewModel(audio: section)
                    audios.append(viewModel)
                }
            }
        }

        if let innserAudios = catalog?.audios?.sortedArray(using: sortBy) as? [RTCatalog] {
            for audio in innserAudios {
                if audio.isLink() {
                    audio.sectionCatalog = audio.audioCatalog
                    let viewModel = CatalogViewModel(catalog: audio)
                    sections.append(viewModel)
                    accessoryType = .disclosureIndicator
                }
                else if audio.isAudio() {
                    let viewModel = AudioViewModel(audio: audio)
                    audios.append(viewModel)
                }
            }
        }        
    }
    
    func iconText() -> String {
        return "\(Commons.symbols.showAwesome(icon: icon))"
    }
    
    func urlString() -> String? {
        return url?.absoluteString
    }
    
}
