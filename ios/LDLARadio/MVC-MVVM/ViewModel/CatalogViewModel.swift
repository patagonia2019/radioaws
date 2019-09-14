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
class CatalogViewModel: BaseViewModelProtocol {

    let icon: Commons.symbols.FontAwesome = .indent
    let iconColor = UIColor.lavender

    var url: URL?
    static let cellheight: Float = UIScreen.main.traitCollection.userInterfaceIdiom == .pad ? 100 : 70

    var placeholderImageName: String?
    var placeholderImage: UIImage?

    var selectionStyle = UITableViewCell.SelectionStyle.blue
    var accessoryType = UITableViewCell.AccessoryType.disclosureIndicator

    var detail: LabelViewModel = LabelViewModel(text: "No more detail", color: UIColor.clover, font: UIFont(name: Commons.font.regular, size: Commons.font.size.XS), isHidden: true, lines: 1)

    var isBookmark: Bool?
    var title: LabelViewModel = LabelViewModel(text: "No more info", color: UIColor.orchid, font: UIFont(name: Commons.font.bold, size: Commons.font.size.M), isHidden: true, lines: 1)

    var tree: String = ""

    var sections = [CatalogViewModel]()
    var audios = [AudioViewModel]()

    var isExpanded: Bool?
    var thumbnailUrl: URL?

    var section: String = ""
    var text: String?

    /// convenient id
    var parentId: String?
    var id: String?
    var page: Int = 1

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
        id = catalog?.guideId ?? catalog?.genreId ?? catalog?.presetId
        if let parent = catalog?.sectionCatalog ?? catalog?.audioCatalog {
            parentId = parent.guideId ?? parent.genreId ?? parent.presetId
        }

        if let catalog = catalog,
            let text = catalog.text ?? catalog.subtext {
            detail.text = catalog.isOnlyText() ? text : ""
        }
        if let queryUrl = catalog?.url?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
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
                    } else {
                        element.audioCatalog = element.sectionCatalog
                        element.sectionCatalog = nil
                    }
                }
                let viewModel = AudioViewModel(audio: element)
                audiosTmp.append(viewModel)
            } else {
                if element.sectionCatalog == nil {
                    if element.audioCatalog == nil {
                        element.sectionCatalog = catalog
                    } else {
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

        isBookmark = checkIfBookmarked()
        if audios.count > 0 && sections.count == 0 {
            isExpanded = nil
        }
        
        placeholderImageName = RTCatalog.placeholderImageName
        if let imageName = placeholderImageName {
            placeholderImage = UIImage.init(named: imageName)
        }

    }

    init(archiveCollection: ArchiveCollection?, isAlreadyExpanded: Bool = false) {
        id = archiveCollection?.identifier
        section = AudioViewModel.ControllerName.archiveOrg.rawValue
        title.text = archiveCollection?.title ?? ""
        tree = ""
        detail.text = archiveCollection?.detail ?? ""

        if let imageUrl = archiveCollection?.thumbnailUrlString()?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let urlChecked = URL(string: imageUrl) {
            thumbnailUrl = urlChecked
        }

        if let queryUrl = archiveCollection?.urlString()?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let urlChecked = URL(string: queryUrl) {
            url = urlChecked
        }

        if let metas = archiveCollection?.metas {
            page = metas.count
            for meta in metas {
                if let response = (meta as? ArchiveMeta)?.response,
                    let docs = response.docs {
                    sections.append(contentsOf: docs.map({ CatalogViewModel(archiveDoc: $0 as? ArchiveDoc, isAlreadyExpanded: isAlreadyExpanded, superTree: title.text) }))
                }
            }
        }

        isBookmark = checkIfBookmarked()
        isExpanded = isAlreadyExpanded

        text = detail.text
        
        placeholderImageName = ArchiveDoc.placeholderImageName
        if let imageName = placeholderImageName {
            placeholderImage = UIImage.init(named: imageName)
        }

    }

    init(archiveDoc: ArchiveDoc?, isAlreadyExpanded: Bool = false, superTree: String?) {
        id = archiveDoc?.identifier
        parentId = archiveDoc?.response?.meta?.identifier ?? archiveDoc?.response?.meta?.collectionIdentifier
        section = AudioViewModel.ControllerName.archiveOrg.rawValue
        var str = [String]()
        if let adtitle = archiveDoc?.title {
            str.append(String(adtitle.prefix(256)))
        }
        if let adsubject = archiveDoc?.subject {
            str.append(String(adsubject.prefix(256)))
        }
        if let adcreator = archiveDoc?.creator {
            str.append(String(adcreator.prefix(256)))
        }
        title.text = str.joined(separator: ", ")
        tree = superTree ?? ""
        detail.text = String(archiveDoc?.descript?.prefix(1024) ?? "")

        if let imageUrl = archiveDoc?.thumbnailUrlString()?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let urlChecked = URL(string: imageUrl) {
            thumbnailUrl = urlChecked
        }

        if let queryUrl = archiveDoc?.urlString()?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let urlChecked = URL(string: queryUrl) {
            url = urlChecked
        }

        isBookmark = checkIfBookmarked()

        var textStr = [String]()
        if tree.count > 0 {
            textStr.append(tree)
        }
        if let adtitle = archiveDoc?.title {
            textStr.append("Title: \(adtitle)")
        }
        if let adsubject = archiveDoc?.subject {
            textStr.append("Subject: \(adsubject)")
        }
        if let adcreator = archiveDoc?.creator {
            textStr.append("Creator: \(adcreator)")
        }
        if let descript = archiveDoc?.descript {
            textStr.append(descript)
        }
        if let publicDate = archiveDoc?.publicDate {
            textStr.append("Date of Publish: \(publicDate)")
        }

        text = textStr.joined(separator: ".\n")
        if sections.count == 0 {
            isExpanded = nil
        } else {
            isExpanded = isAlreadyExpanded
        }
        
        let sortByTitle = [NSSortDescriptor(key: "title", ascending: true)]
        if let archiveFiles = archiveDoc?.detail?.archiveFiles?.sortedArray(using: sortByTitle),
            archiveFiles.count > 0 {
            audios = archiveFiles.map({ AudioViewModel(archiveFile: $0 as? ArchiveFile) })
        }
        
        placeholderImageName = ArchiveDoc.placeholderImageName
        if let imageName = placeholderImageName {
            placeholderImage = UIImage.init(named: imageName)
        }

    }

    init(desconcierto: Desconcierto?, isAlreadyExpanded: Bool = false) {
        if let desconciertoId = desconcierto?.id {
            id = "\(desconciertoId)"
        }
        section = AudioViewModel.ControllerName.desconcierto.rawValue
        title.text = desconcierto?.date ?? ""
        tree = ""
        detail.text = ""
        let queryUrl = "\(RestApi.Constants.Service.ldlaServer)/desconciertos/\(desconcierto?.id ?? 0).json"
        if let urlChecked = URL(string: queryUrl) {
            url = urlChecked
        }
        var order: Int = 0
        for streamUrl in [desconcierto?.streamUrl1, desconcierto?.streamUrl2, desconcierto?.streamUrl3] {
            order = order + 1
            let audio = AudioViewModel(desconcierto: desconcierto, audioUrl: streamUrl, order: order)
            if audio.url?.absoluteString.count ?? 0 > 0 {
                audios.append(audio)
            }
        }
        isBookmark = checkIfBookmarked()
        isExpanded = isAlreadyExpanded

        text = desconcierto?.obs ?? ""

        placeholderImageName = Desconcierto.placeholderImageName
        if let imageName = placeholderImageName {
            placeholderImage = UIImage.init(named: imageName)
        }

    }

    /// to know if the model is in bookmark
    func checkIfBookmarked() -> Bool? {
        if audios.count > 0 {
            return audios.filter({ (audio) -> Bool in
                return audio.isBookmark ?? false
            }).count == audios.count
        } else {
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
