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

    enum Section: Int {
        case model0 = 0
        case model1
        case model2
        case model3
        case model4
        case model5
        case count
    }

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

    let icon = Commons.symbols.FontAwesome.music
    let iconColor = UIColor.darkGray

    var url: URL?

    var selectionStyle = UITableViewCell.SelectionStyle.blue
    var accessoryType = UITableViewCell.AccessoryType.none

    var detail: LabelViewModel = LabelViewModel(text: "", color: .darkGray, font: UIFont(name: Commons.font.regular, size: Commons.font.size.S), isHidden: true, lines: 1)

    var text: String?

    var isBookmark: Bool?

    var isDownloading: Bool = false

    var downloadFiles: [String]?

    var isFullScreen: Bool = false

    var title = LabelViewModel()

    var subTitle = LabelViewModel(text: "", color: UIColor.cayenne, font: UIFont(name: Commons.font.bold, size: Commons.font.size.S), isHidden: false, lines: 1)

    /// convenient id
    var id: String?

    /// thumbnail url and placeholders
    var thumbnailUrl: URL?
    var placeholderImageName: String?
    var placeholderImage: UIImage?
    var image: UIImage?

    var info: String = ""

    var isPlaying: Bool = false
    var hasDuration: Bool = false

    var section: String = ""

    var error: JFError?

    /// initialization of the view model for RT catalog audios
    init(audio: RTCatalog?) {
        id = audio?.guideId ?? audio?.presetId ?? audio?.genreId

        var textStr = [String()]

        section = ControllerName.radioTime.rawValue
        title.text = audio?.titleAndText() ?? ""
        if let subtext = audio?.subtext {
            textStr.append(subtext)
        }
        subTitle.text = audio?.subtext ?? ""

        if let playing = audio?.playing {
            detail.text = playing
        } else {
            detail.text = ""
        }
        if let currentTrack = audio?.currentTrack,
            subTitle.text != currentTrack {
            if let currentTrack = audio?.currentTrack {
                textStr.append(currentTrack)
            }
            detail.text = "\(detail.text) \(currentTrack)"
        }

        if let bitrate = audio?.bitrate {
            textStr.append(bitrate + " kbps")
        }

        if let formats = audio?.formats {
            textStr.append(formats)
        }
        text = textStr.joined(separator: ". ")

        placeholderImageName = RTCatalog.placeholderImageName
        if let imageName = placeholderImageName {
            placeholderImage = UIImage.init(named: imageName)
        }

        if let imageUrl = audio?.image?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let urlChecked = URL(string: imageUrl) {
            thumbnailUrl = urlChecked
        }
        if let audioUrl = audio?.url?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let urlChecked = URL(string: audioUrl) {
            url = urlChecked
        }
        isBookmark = checkIfBookmarked()
        isPlaying = StreamPlaybackManager.instance.isAboutToPlay(url: urlString())
        reFillTitles()
        if detail.text.count <= 0 {
            detail.text = audio?.audioCatalog?.titleTree() ?? audio?.sectionCatalog?.titleTree() ?? ""
        }
        hasDuration = false
    }

    /// initialization of the view model for LDLA stream audios
    init(stream: Stream?) {
        section = ControllerName.suggestion.rawValue
        if let streamId = stream?.id {
            id = "\(streamId)"
        }
        title.text = stream?.station?.name ?? ""
        subTitle.text = (stream?.station?.city?.name ?? "") + " " + (stream?.station?.city?.district?.name ?? "")
        detail.text = stream?.station?.tuningDial ?? ""

        text = subTitle.text + ". " + detail.text

        placeholderImageName = Stream.placeholderImageName
        if let imageName = placeholderImageName {
            placeholderImage = UIImage.init(named: imageName)
        }

        if let imageUrl = stream?.station?.imageUrl?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let urlChecked = URL(string: imageUrl) {
            thumbnailUrl = urlChecked
        }
        if let audioUrl = stream?.url?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let urlChecked = URL(string: audioUrl) {
            url = urlChecked
        }
        isBookmark = checkIfBookmarked()
        isPlaying = StreamPlaybackManager.instance.isAboutToPlay(url: urlString())
        reFillTitles()
        info = ""
        hasDuration = false
    }

    init(archiveFile: ArchiveFile?) {

        section = ControllerName.archiveOrg.rawValue
        id = archiveFile?.original

        var titleStr = [String]()
        if let title = archiveFile?.title {
            titleStr.append(title)
        }
        if let album = archiveFile?.album {
            titleStr.append(album)
        }
        if let docTitle = archiveFile?.detail?.doc?.title {
            titleStr.append(docTitle)
        }
        title.text = titleStr.joined(separator: ". ")

        var subtitleStr = [String]()
        if let creator = archiveFile?.detail?.doc?.creator {
            subtitleStr.append(creator)
        }
        if let artist = archiveFile?.artist {
            subtitleStr.append(artist)
        }
        if let format = archiveFile?.format {
            subtitleStr.append(format)
        }
        subTitle.text = subtitleStr.joined(separator: ". ")

        var detailStr = [String]()
        if let original = archiveFile?.original {
            detailStr.append(original)
        }
        detail.text = detailStr.joined(separator: ". ")

        var textStr = [String]()
        textStr.append(title.text)
        textStr.append(subTitle.text)
        textStr.append(detail.text)
        textStr.append(archiveFile?.detail?.doc?.descript ?? archiveFile?.description ?? "")
        text = textStr.joined(separator: "\n")

        placeholderImageName = ArchiveDoc.placeholderImageName
        if let imageName = placeholderImageName {
            placeholderImage = UIImage.init(named: imageName)
        }
        if let imageUrl = archiveFile?.detail?.image?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let urlChecked = URL(string: imageUrl) {
            thumbnailUrl = urlChecked
        }

        if let audioUrl = archiveFile?.urlString()?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let urlChecked = URL(string: audioUrl) {
            url = urlChecked
        }
        isBookmark = checkIfBookmarked()
        isPlaying = StreamPlaybackManager.instance.isAboutToPlay(url: urlString())
        reFillTitles()
        hasDuration = true
    }

    /// initialization of the view model for LDLA stream audios
    init(desconcierto: Desconcierto?, audioUrl: String?, order: Int) {
        section = ControllerName.desconcierto.rawValue
        id = "\((Int(desconcierto?.id ?? 0) * 1000) + order)"
        if let name = audioUrl?.components(separatedBy: "/").last?.removingPercentEncoding,
            name.contains("alt=media&token") == false {
            title.text = name
        } else {
            title.text = "ED-\(desconcierto?.date ?? "file")-\(order).mp3"
        }
        subTitle.text = ""
        detail.text = "El Desconcierto, de Quique Pesoa"

        placeholderImageName = Desconcierto.placeholderImageName
        if let imageName = placeholderImageName {
            placeholderImage = UIImage.init(named: imageName)
        }

        if let urlChecked = URL(string: "http://www.eldesconcierto.com.ar/wp-content/uploads/2018/03/logo-quique-pesoa-app-200.png") {
            thumbnailUrl = urlChecked
        }
        if let audioUrl = audioUrl,
            let urlChecked = URL(string: audioUrl) {
            url = urlChecked
        }
        isBookmark = checkIfBookmarked()
        isPlaying = StreamPlaybackManager.instance.isAboutToPlay(url: urlString())
        reFillTitles()
        info = ""
        hasDuration = true
    }

    /// initialization of the view model for RNA audios
    init(stationAm: RNAStation?) {
        update(station: stationAm, isAm: true)
    }

    init(stationFm: RNAStation?) {
        update(station: stationFm, isAm: false)
    }

    /// initialization of the view model for bookmarked audios
    init(audio: Audio?) {
        section = audio?.section ?? ControllerName.bookmark.rawValue
        detail.text = audio?.detail ?? ""
        id = audio?.id ?? ""
        placeholderImageName = audio?.placeholder
        if let imageName = placeholderImageName {
            placeholderImage = UIImage.init(named: imageName)
        }
        subTitle.text = audio?.subTitle ?? ""
        if let imageUrl = audio?.thumbnailUrl,
            let urlChecked = URL(string: imageUrl) {
            thumbnailUrl = urlChecked
        }
        if let audioUrl = audio?.urlString,
            let urlChecked = URL(string: audioUrl) {
            url = urlChecked
        }
        title.text = audio?.title ?? ""
        isBookmark = true
    }

    func urlString() -> String? {
        return url?.absoluteString
    }

    /// to know if the model is in bookmark
    func checkIfBookmarked() -> Bool {
        return Audio.search(byUrl: url?.absoluteString)?.isBookmark ?? false
    }

    /// Use the url of the stream/audio as an AVURLAsset
    func urlAsset() -> AVURLAsset? {
        guard let url = url else { return nil }
        return AVURLAsset(url: url)
    }

    func height() -> Float {
        return UIScreen.main.traitCollection.userInterfaceIdiom == .pad ? 120 : 75
    }
}

/// RNA Station method for update
extension AudioViewModel {
    public  func update(station: RNAStation?, isAm: Bool) {
        section = ControllerName.rna.rawValue
        id = station?.id
        title.text = station?.firstName ?? ""
        subTitle.text = station?.lastName ?? ""
        detail.text = (isAm ? station?.dialAM : station?.dialFM) ?? ""
        let currentProgram = isAm ? station?.amCurrentProgram : station?.fmCurrentProgram
        if let programName = currentProgram?.programName {
            if detail.count > 0 {
                detail.text += " "
            }
            detail.text += programName
        }
        placeholderImageName = RNAStation.placeholderImageName
        if let imageName = placeholderImageName {
            placeholderImage = UIImage.init(named: imageName)
        }

        thumbnailUrl = imageUrl(usingUri: station?.image)
            ?? imageUrl(usingUri: currentProgram?.image)
            ?? imageUrl(usingUri: currentProgram?.imageStation)

        url = streamUrl(usingBaseUrl: station?.url1, port: station?.port, bandUri: isAm ? station?.amUri : station?.fmUri)
            ?? streamUrl(usingBaseUrl: station?.url2, port: station?.port, bandUri: isAm ? station?.amUri : station?.fmUri)

        isBookmark = checkIfBookmarked()
        isPlaying = StreamPlaybackManager.instance.isAboutToPlay(url: urlString())
        reFillTitles()
        info = ""
        hasDuration = false
    }
}

/// some private stuff for the view model
extension AudioViewModel {

    private func imageUrl(usingUri uri: String?) -> URL? {
        if let uri = uri, uri.count > 0,
            let urlChecked = URL(string: RestApi.Constants.Service.url(with: "/files/\(uri)", baseUrl: RestApi.Constants.Service.rnaServer)) {
            return urlChecked
        }
        return nil
    }

    private func streamUrl(usingBaseUrl baseUrl: String?, port: String?, bandUri: String?) -> URL? {
        if let baseUrl = baseUrl, baseUrl.count > 0,
            let bandUri = bandUri, bandUri.count > 0,
            let port = port, port.count > 0,
            let urlChecked = URL(string: "http://\(baseUrl):\(port)\(bandUri)") {
            return urlChecked
        }
        return nil
    }

    private func reFillTitles() {
        if title.count > 0 && subTitle.count > 0 && detail.count > 0 {
            info = [title.text, subTitle.text, detail.text].joined(separator: ". ")
            return
        }
        var titles = [String]()
        if title.count > 0 {
            titles.append(title.text)
        }
        if subTitle.count > 0 {
            titles.append(subTitle.text)
        }
        if detail.count > 0 {
            titles.append(detail.text)
        }
        detail.text = ""
        detail.isHidden = true
        if titles.count == 2 {
            title.text = titles[0]
            subTitle.text = titles[1]
            detail.isHidden = true
            title.lines = 2
        } else if titles.count == 1 {
            title.text = titles[0]
            subTitle.text = ""
            subTitle.isHidden = true
            title.lines = 3
        }
        info = [title.text, subTitle.text, detail.text].joined(separator: ". ")
    }

}
