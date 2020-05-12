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
        case playing = "Playing"
        case suggestion = "Los Locos"
        case radioTime = "Radio Time"
        case rna = "RNA"
        case bookmark = "My Pick"
        case desconcierto = "El Desconcierto"
        case archiveOrg = "Archive.org"
        case archiveMainModelOrg = "Archive.org "
        case search = "Search"
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
    var subTitle = LabelViewModel(text: "", color: UIColor.cayenne, font: UIFont(name: Commons.Font.bold, size: Commons.Font.Size.S), isHidden: false, lines: 1)
    var detail: LabelViewModel = LabelViewModel(text: "", color: .darkGray, font: UIFont(name: Commons.Font.regular, size: Commons.Font.Size.S), isHidden: true, lines: 1)
    var info: String?
    var thumbnailUrl: URL?
    var placeholderImageName: String?
    var placeholderImage: UIImage?

    /// initialization of the view model for RT catalog audios
    init(catalog: RTCatalog?) {
        section = ControllerName.radioTime.rawValue
        guard let audio = catalog else { fatalError() }
        id = audio.audioIdentifier
        title.text = audio.titleText
        subTitle.text = audio.subTitleText
        detail.text = audio.detailText
        info = audio.infoText
        section = ControllerName.radioTime.rawValue
        placeholderImage = audio.placeholderImage
        thumbnailUrl = audio.portraitUrl
        url = audio.audioUrl
    }

    /// initialization of the view model for LDLA stream audios
    init(stream: Stream?) {
        section = ControllerName.suggestion.rawValue

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
        section = ControllerName.archiveOrg.rawValue
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
        section = ControllerName.desconcierto.rawValue

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
        section = ControllerName.rna.rawValue

        guard let station = station else { fatalError() }
        id = station.audioIdentifier
        title.text = station.titleText
        subTitle.text = station.subTitleText
        info = station.infoText
        placeholderImage = station.placeholderImage

        if isAm {
            guard let stationAm = station as? RNAStationAM else { fatalError() }
            detail.text = stationAm.detailText
            thumbnailUrl = stationAm.portraitUrl
            url = stationAm.audioUrl
        } else {
            guard let stationFm = station as? RNAStationFM else { fatalError() }
            detail.text = stationFm.detailText
            thumbnailUrl = stationFm.portraitUrl
            url = stationFm.audioUrl
        }
    }
    
    /// initialization of the view model for bookmarked audios
    init(audio: Audio?) {
        guard let audio = audio else { fatalError() }
        section = audio.section ?? ControllerName.bookmark.rawValue
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
