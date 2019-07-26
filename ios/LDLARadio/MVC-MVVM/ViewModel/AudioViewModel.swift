//
//  AudioViewModel.swift
//  LDLARadio
//
//  Created by fox on 15/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import AVFoundation

// This view model will be responsible of render out information in the views for Audio info
struct AudioViewModel {
    
    /// Some constants hardcoded here
    public struct hardcode {
        static let cellheight: Float = 75
        static let identifier: String = "AudioIdentifier"
    }
    
    /// title specification
    var title: String = ""
    var titleColor: UIColor = .darkGray
    var titleFont: UIFont? = UIFont(name: Commons.font.name, size: Commons.font.size.L)
    var titleHide: Bool = false
    var titleLines: Int = 1

    /// subtitle spec
    var subTitle: String = ""
    var subTitleColor: UIColor = .lightGray
    var subTitleFont: UIFont? = UIFont(name: Commons.font.name, size: Commons.font.size.M)
    var subTitleHide: Bool = false
    var subTitleLines: Int = 1

    /// detail spec
    var detail: String = ""
    var detailColor: UIColor = UIColor(white: 0.4, alpha: 0.8)
    var detailFont: UIFont? = UIFont(name: Commons.font.name, size: Commons.font.size.S)
    var detailHide: Bool = false
    var detailLines: Int = 1

    /// convenient id
    var id: String? = nil
    
    /// url of the audio / stream / http /etc
    var url: URL? = nil
    
    /// thumbnail url and placeholders
    var thumbnailUrl: URL? = nil
    var placeholderImageName: String? = nil
    var placeholderImage: UIImage? = nil
    let selectionStyle: UITableViewCell.SelectionStyle = .none
    
    /// to know if the player will work or it's a webkit only play recommendation (like to play the stream in safari)
    var useWeb: Bool = false
    
    var isBookmarked: Bool = false
    
    /// initialization of the view model for RT catalog audios
    init(audio: RTCatalog?) {
        assert(audio?.isAudio() ?? false)
        id = audio?.guideId ?? audio?.presetId ?? audio?.genreId
        title = audio?.titleOrText() ?? ""
        subTitle = audio?.subtext ?? ""
        if let bitrate = audio?.bitrate {
            detail = "\(bitrate) Kbps"
        }
        else {
            detail = ""
        }
        if let currentTrack = audio?.currentTrack,
            subTitle != currentTrack {
                detail = "\(detail) \(currentTrack)"
        }
        
        
        placeholderImageName = Stream.placeholderImageName
        if let imageName = placeholderImageName {
            placeholderImage = UIImage.init(named: imageName)
        }

        if let imageUrl = audio?.image,
            let urlChecked = URL(string: imageUrl),
            UIApplication.shared.canOpenURL(urlChecked) {
            thumbnailUrl = urlChecked
        }
        if let audioUrl = audio?.url,
            let urlChecked = URL(string: audioUrl),
            UIApplication.shared.canOpenURL(urlChecked) {
            url = urlChecked
        }
        isBookmarked = checkIfBookmarked()
        reFillTitles()
    }
    
    private mutating func reFillTitles() {
        if title.count > 0 && subTitle.count > 0 && detail.count > 0 {
            return
        }
        var titles = [String]()
        if title.count > 0 {
            titles.append(title)
        }
        if subTitle.count > 0 {
            titles.append(subTitle)
        }
        if detail.count > 0 {
            titles.append(detail)
        }
        detail = ""
        detailHide = true
        if titles.count == 2 {
            title = titles[0]
            subTitle = titles[1]
            detailHide = true
            titleLines = 2
        }
        else if titles.count == 1 {
            title = titles[0]
            subTitle = ""
            subTitleHide = true
            titleLines = 3
        }
    }
    
    /// initialization of the view model for LDLA stream audios
    init(stream: Stream?) {
        id = "\(stream?.id ?? 0)"
        title = stream?.station?.name ?? ""
        subTitle = stream?.station?.city?.name ?? ""
        detail = stream?.station?.city?.district?.name ?? ""
    
        placeholderImageName = Stream.placeholderImageName
        if let imageName = placeholderImageName {
            placeholderImage = UIImage.init(named: imageName)
        }

        if let imageUrl = stream?.station?.imageUrl,
            let urlChecked = URL(string: imageUrl),
            UIApplication.shared.canOpenURL(urlChecked) {
            thumbnailUrl = urlChecked
        }
        if let audioUrl = stream?.url,
            let urlChecked = URL(string: audioUrl),
            UIApplication.shared.canOpenURL(urlChecked) {
            url = urlChecked
        }
        isBookmarked = checkIfBookmarked()
        reFillTitles()

    }
    
    
    /// initialization of the view model for RNA audios
    init(stationAm: RNAStation?) {
        update(station: stationAm, isAm: true)
    }
    
    init(stationFm: RNAStation?) {
        update(station: stationFm, isAm: false)
    }
    
    /// initialization of the view model for bookmarked audios
    init(bookmark: Bookmark?) {
        detail = bookmark?.detail ?? ""
        id = bookmark?.id
        placeholderImageName = bookmark?.placeholder
        if let imageName = placeholderImageName {
            placeholderImage = UIImage.init(named: imageName)
        }
        subTitle = bookmark?.subTitle ?? ""
        if let imageUrl = bookmark?.thumbnailUrl,
            let urlChecked = URL(string: imageUrl),
            UIApplication.shared.canOpenURL(urlChecked) {
            thumbnailUrl = urlChecked
        }
        if let audioUrl = bookmark?.url,
            let urlChecked = URL(string: audioUrl),
            UIApplication.shared.canOpenURL(urlChecked) {
            url = urlChecked
        }
        title = bookmark?.title ?? ""
        useWeb = bookmark?.useWeb ?? false
        isBookmarked = true
    }
    
    func urlString() -> String? {
        return url?.absoluteString
    }
    
    static func height() -> Float {
        return hardcode.cellheight
    }
    
    /// to know if the model is in bookmark
    func checkIfBookmarked() -> Bool {
        if let id = id, let url = url?.absoluteString {
            return Bookmark.fetch(id: id, url: url) != nil
        }
        return false
    }
    
    /// Use the url of the stream/audio as an AVURLAsset
    func urlAsset() -> AVURLAsset? {
        guard let playUrl = urlString()?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let streamPlaylistURL = URL(string: playUrl) else { return nil }
        print("play = \(streamPlaylistURL)")
        return AVURLAsset(url: streamPlaylistURL)
    }
    
}

/// RNA Station method for update
extension AudioViewModel {
    public mutating func update(station: RNAStation?, isAm: Bool) {
        id = station?.id
        title = station?.firstName ?? ""
        subTitle = station?.lastName ?? ""
        detail = (isAm ? station?.dialAM : station?.dialFM) ?? ""
        let currentProgram = isAm ? station?.amCurrentProgram : station?.fmCurrentProgram
        if let programName = currentProgram?.programName {
            if detail.count > 0 {
                detail += " "
            }
            detail += programName
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
        
        isBookmarked = checkIfBookmarked()
        reFillTitles()
    }

}


/// some private stuff for the view model
extension AudioViewModel {
    
    private func imageUrl(usingUri uri: String?) -> URL? {
        if let uri = uri, uri.count > 0,
            let urlChecked = URL(string: RestApi.Constants.Service.url(with: "/files/\(uri)", baseUrl: RestApi.Constants.Service.rnaServer)),
            UIApplication.shared.canOpenURL(urlChecked)
        {
            return urlChecked
        }
        return nil
    }
    
    private func streamUrl(usingBaseUrl baseUrl: String?, port: String?, bandUri: String?) -> URL? {
        if let baseUrl = baseUrl, baseUrl.count > 0,
            let bandUri = bandUri, bandUri.count > 0,
            let port = port, port.count > 0,
            let urlChecked = URL(string: "http://\(baseUrl):\(port)\(bandUri)"),
            UIApplication.shared.canOpenURL(urlChecked)
        {
            return urlChecked
        }
        return nil
    }

}
