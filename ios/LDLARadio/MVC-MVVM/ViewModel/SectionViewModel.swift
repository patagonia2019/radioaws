//
//  SectionViewModel.swift
//  LDLARadio
//
//  Created by fox on 13/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

// This view model will be responsible of render out information in the views for Catalog info
class SectionViewModel: BaseViewModelProtocol {

    let icon: Commons.Symbol.FontAwesome = .indent
    let iconColor = UIColor.lavender

    var url: URL?

    var placeholderImageName: String?
    var placeholderImage: UIImage?

    var selectionStyle = UITableViewCell.SelectionStyle.blue
    var accessoryType = UITableViewCell.AccessoryType.none

    var detail: LabelViewModel = LabelViewModel(color: UIColor.clover, font: UIFont(name: Commons.Font.regular, size: Commons.Font.Size.XS), isHidden: true, lines: 0)

    var title: LabelViewModel = LabelViewModel(color: UIColor.orchid, font: UIFont(name: Commons.Font.bold, size: Commons.Font.Size.S), isHidden: true, lines: 0)
    
    var attributedText: NSAttributedString {
        let attributedText = NSMutableAttributedString()
        for labelModel in [title, detail] {
            if let attributed = labelModel.attributedText {
                attributedText.append(attributed)
            }
        }
        return attributedText
    }

    var tree: String?

    var sections = [SectionViewModel]()
    var audios = [AudioViewModel]()

    var isCollapsed: Bool?
    var thumbnailUrl: URL?

    var section: String = ""
    var text: String?

    /// convenient id
    var parentId: String?
    var id: String?
    var showSeparator: Bool = true

    var isBookmark: Bool {
        if !audios.isEmpty {
            return audios.filter({ (audio) -> Bool in
                audio.isBookmark
            }).count == audios.count
        } else {
            return false
        }
    }

    init() {
        title.text = nil
        detail.text = nil
        selectionStyle = .none
        accessoryType = .none
    }

    init(catalog: RTCatalog?) {
        reload(catalog: catalog)
    }
    
    func reload(catalog: RTCatalog?) {
        guard let catalog = catalog else { return }
        id = catalog.sectionIdentifier
        section = AudioViewModel.ControllerName.RT.rawValue
        title.text = catalog.titleText
        tree = catalog.titleTree
        parentId = catalog.parentId
        detail.text = catalog.sectionDetailText
        url = catalog.queryUrl
        placeholderImage = catalog.placeholderImage
        let content = catalog.content
        sections = content.0.map({ SectionViewModel(catalog: $0) })
        audios = content.1.map({ AudioViewModel(catalog: $0) })
        isCollapsed = catalog.isCollapsed || (sections.isEmpty && audios.isEmpty)
    }

    init(archiveCollection: ArchiveCollection?, isAlreadyCollapsed: Bool = true) {
        reload(archiveCollection: archiveCollection, isAlreadyCollapsed: isAlreadyCollapsed)
    }
    
    func reload(archiveCollection: ArchiveCollection?, isAlreadyCollapsed: Bool = true) {
        guard let archiveCollection = archiveCollection else { fatalError() }
        id = archiveCollection.sectionIdentifier
        section = AudioViewModel.ControllerName.ArchiveOrg.rawValue
        title.text = archiveCollection.titleText
        detail.text = archiveCollection.sectionDetailText
        thumbnailUrl = archiveCollection.portraitUrl
        url = archiveCollection.queryUrl
        text = archiveCollection.infoText
        placeholderImage = archiveCollection.placeholderImage
        let content = archiveCollection.content
        sections = content.0.map({ SectionViewModel(archiveDoc: $0, isAlreadyCollapsed: isAlreadyCollapsed) })
        audios = []
        isCollapsed = isAlreadyCollapsed || sections.isEmpty
    }

    init(archiveDoc: ArchiveDoc?, isAlreadyCollapsed: Bool = true) {
        guard let archiveDoc = archiveDoc else { fatalError() }
        id = archiveDoc.sectionIdentifier
        parentId = archiveDoc.parentId
        section = AudioViewModel.ControllerName.ArchiveOrg.rawValue
        title.text = archiveDoc.titleText
        detail.text = archiveDoc.sectionDetailText
        thumbnailUrl = archiveDoc.portraitUrl
        url = archiveDoc.queryUrl
        text = archiveDoc.infoText
        placeholderImage = archiveDoc.placeholderImage
        sections = []
        audios = archiveDoc.content.1.map({ AudioViewModel(archiveFile: $0) })
        isCollapsed = isAlreadyCollapsed || audios.isEmpty
    }

    init(desconcierto: Desconcierto?, isAlreadyCollapsed: Bool = true) {
        guard let desconcierto = desconcierto else { fatalError() }
        id = desconcierto.sectionIdentifier
        section = AudioViewModel.ControllerName.Desconcierto.rawValue
        title.text = desconcierto.titleText
        tree = ""
        detail.text = desconcierto.sectionDetailText
        url = desconcierto.queryUrl
        let contentAudios = desconcierto.content.1
        audios = contentAudios.map({ AudioViewModel(desconcierto: desconcierto, audioUrl: $0, order: ( contentAudios.firstIndex(of: $0) ?? 0) + 1 ) })
        isCollapsed = isAlreadyCollapsed || audios.isEmpty
        text = desconcierto.infoText
        
        placeholderImageName = Desconcierto.placeholderImageName
        if let imageName = placeholderImageName {
            placeholderImage = UIImage.init(named: imageName)
        }
    }

    func iconText() -> String {
        return "\(Commons.Symbol.showAwesome(icon: icon))"
    }

    func urlString() -> String? {
        return url?.absoluteString
    }
}
