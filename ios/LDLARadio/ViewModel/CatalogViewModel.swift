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
        title = catalog?.title ?? ""
        detail = catalog?.text ?? ""
        if let queryUrl = catalog?.url {
            if let urlChecked = URL(string: queryUrl),
                UIApplication.shared.canOpenURL(urlChecked) {
                url = urlChecked
                accessoryType = .disclosureIndicator
            }
        }
        let sortBy = [NSSortDescriptor(key: "text", ascending: true)]
        if let innerSections = catalog?.sections?.sortedArray(using: sortBy) as? [RTCatalog] {
            for section in innerSections {
                if section.isLink() {
                    sections.append(CatalogViewModel(catalog: section))
                }
                else if section.isAudio() {
                    audios.append(AudioViewModel(audio: section))
                }
            }
        }

        if let innserAudios = catalog?.audios?.sortedArray(using: sortBy) as? [RTCatalog] {
            for audio in innserAudios {
                if audio.isLink() {
                    sections.append(CatalogViewModel(catalog: audio))
                }
                else if audio.isAudio() {
                    audios.append(AudioViewModel(audio: audio))
                }
            }
        }
        
//        if let innerSections = catalog?.sections?.sortedArray(using: [NSSortDescriptor(key: "text", ascending: true)]), innerSections.count > 0 {
//            sections.append(contentsOf: innerSections.filter({ s -> Bool in
//                return (s as? RTCatalog)?.isLink() ?? false
//            }).map { return CatalogViewModel(catalog: $0 as? RTCatalog) })
//            audios.append(contentsOf: (innerSections.filter({ s -> Bool in
//                return (s as? RTCatalog)?.isAudio() ?? false
//            }).map { return AudioViewModel(audio: $0 as? RTCatalog) }))
//        }
//        if let innerAudios = catalog?.audios?.sortedArray(using: [NSSortDescriptor(key: "text", ascending: true)]).filter({ (s) -> Bool in
//            return (s as? RTCatalog)?.isAudio() ?? false
//        }), innerAudios.count > 0 {
//            audios = innerAudios.map { return AudioViewModel(audio: $0 as? RTCatalog) }
//        }
//        if let innerSections = catalog?.sections?.sortedArray(using: [NSSortDescriptor(key: "text", ascending: true)]), innerSections.count > 0 {
//            sections = innerSections.map { return CatalogViewModel(catalog: $0 as? RTCatalog) }
//        }
//        if let innerAudios = catalog?.audios?.sortedArray(using: [NSSortDescriptor(key: "text", ascending: true)]), innerAudios.count > 0 {
//            audios = innerAudios.map { return AudioViewModel(audio: $0 as? RTCatalog) }
//        }
    }
    
    func iconText() -> String {
        return "\(Commons.symbols.showAwesome(icon: icon))"
    }
    
    func urlString() -> String? {
        return url?.absoluteString
    }
    
}
