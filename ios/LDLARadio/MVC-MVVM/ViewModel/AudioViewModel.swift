//
//  AudioViewModel.swift
//  LDLARadio
//
//  Created by fox on 15/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import JFCore

// This view model will be responsible of render out information in the views for Audio info
class AudioViewModel: BaseViewModelProtocol {

    enum ControllerName: String {
        
        typealias RawValue = String
        
        case LosLocos = "Los Locos"
        case RT = "Radio Time"
        case RNA = "RNA"
        case MyPick = "My Pick"
        case Desconcierto = "El Desconcierto"
        case ArchiveOrg = "Archive.org"
        case ArchiveOrgMain = "Archive.org "
        case Search = "Search"
        
        func value() -> String {
            return rawValue
        }
    }

    private var observerContext = 0

    let icon = Commons.Symbol.FontAwesome.music
    let iconColor = UIColor.darkGray

    var url: URL?

    var selectionStyle = UITableViewCell.SelectionStyle.blue
    var accessoryType = UITableViewCell.AccessoryType.none

    var isDownloading: Bool = false

    var downloadFiles: [String]?

    var isFullScreen: Bool = false
    
    var image: UIImage?

    var hasDuration: Bool = false

    var error: JFError?
    
    var isTryingToPlay: Bool {
        return StreamPlaybackManager.instance.isTryingToPlay(url: urlString())
    }
    
    var isPlaying: Bool {
        return StreamPlaybackManager.instance.isPlaying(url: urlString())
    }
    
    var isBookmark: Bool {
        return Audio.search(byUrl: url?.absoluteString)?.isBookmark ?? false
    }
    
    /// Related Playable protocol
    var section: String = ""
    var id: String
    var title = LabelViewModel()
    var subTitle = LabelViewModel(color: UIColor.cayenne, font: UIFont(name: Commons.Font.bold, size: Commons.Font.Size.S), isHidden: false, lines: 0)
    var detail: LabelViewModel = LabelViewModel(color: .darkGray, font: UIFont(name: Commons.Font.regular, size: Commons.Font.Size.S), isHidden: true, lines: 0)
    
    var attributedText: NSAttributedString {
        let attributedText = NSMutableAttributedString()
        for labelModel in [title, subTitle, detail] {
            if let attributed = labelModel.attributedText {
                attributedText.append(attributed)
            }
        }
        return attributedText
    }

    var info: String?
    var thumbnailUrl: URL?
    var placeholderImageName: String?
    var placeholderImage: UIImage?
    var showSeparator: Bool = true

    /// initialization of the view model for RT catalog audios
    init(catalog: RTCatalog?) {
        section = ControllerName.RT.rawValue
        guard let audio = catalog else { fatalError() }
        id = audio.audioIdentifier
        title.text = audio.titleText
        subTitle.text = audio.subTitleText
        detail.text = audio.detailText
        info = audio.infoText
        section = ControllerName.RT.rawValue
        placeholderImage = audio.placeholderImage
        thumbnailUrl = audio.portraitUrl
        url = audio.audioUrl
    }

    /// initialization of the view model for LDLA stream audios
    init(stream: Stream?) {
        section = ControllerName.LosLocos.rawValue

        guard let stream = stream else { fatalError() }
        id = stream.audioIdentifier
        title.text = stream.titleText
        subTitle.text = stream.subTitleText
        detail.text = stream.detailText
        info = stream.infoText
        placeholderImage = stream.placeholderImage
        thumbnailUrl = stream.portraitUrl
        url = stream.audioUrl
    }

    init(archiveFile: ArchiveFile?) {
        section = ControllerName.ArchiveOrg.rawValue
        guard let archiveFile = archiveFile else { fatalError() }
        
        id = archiveFile.audioIdentifier
        title.text = archiveFile.titleText
        subTitle.text = archiveFile.subTitleText
        detail.text = archiveFile.detailText
        info = archiveFile.infoText
        placeholderImage = archiveFile.placeholderImage
        thumbnailUrl = archiveFile.portraitUrl
        url = archiveFile.audioUrl
        hasDuration = true
    }

    /// initialization of the view model for LDLA stream audios
    init(desconcierto: Desconcierto?, audioUrl: String?, order: Int) {
        section = ControllerName.Desconcierto.rawValue

        guard let desconcierto = desconcierto,
            let audioUrl = audioUrl else { fatalError() }
        id = "\(order)"
        title.text = desconcierto.titleText
        subTitle.text = desconcierto.subTitleText
        detail.text = "El Desconcierto, de Quique Pesoa"
        info = desconcierto.infoText
        placeholderImage = desconcierto.placeholderImage
        thumbnailUrl = desconcierto.portraitUrl
        url = URL(string: audioUrl)
        hasDuration = true
    }

    /// initialization of the view model for RNA audios
    init(station: RNAStation?, isAm: Bool = false) {
        section = ControllerName.RNA.rawValue

        guard let station = station else { fatalError() }
        id = station.audioIdentifier
        title.text = station.titleText
        subTitle.text = station.subTitleText
        info = station.infoText
        placeholderImage = station.placeholderImage

        if isAm {
            detail.text = station.detailTextAm
            thumbnailUrl = station.portraitUrlAm
            url = station.audioUrlAm
        } else {
            detail.text = station.detailTextFm
            thumbnailUrl = station.portraitUrlFm
            url = station.audioUrlFm
        }
    }
    
    /// initialization of the view model for bookmarked audios
    init(audio: Audio?) {
        guard let audio = audio else { fatalError() }
        section = audio.section ?? ControllerName.MyPick.rawValue
        id = audio.audioIdentifier
        title.text = audio.titleText
        subTitle.text = audio.subTitleText
        detail.text = audio.detailText
        info = audio.infoText
        placeholderImage = audio.placeholderImage
        thumbnailUrl = audio.portraitUrl
        url = audio.audioUrl
    }

}

/// some private stuff for the view model
extension AudioViewModel {

    func urlString() -> String? {
        return url?.absoluteString
    }

    /// Use the url of the stream/audio as an AVURLAsset
    func urlAsset() -> AVURLAsset? {
        guard let url = url else { return nil }
        return AVURLAsset(url: url)
    }

}
