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
struct AudioViewModel : BaseViewModelProtocol {

    let icon = Commons.symbols.FontAwesome.music
    let iconColor = UIColor.darkGray

    var url: URL? = nil
    
    static let cellheight : Float = UIScreen.main.traitCollection.userInterfaceIdiom == .pad ? 120 : 75
    
    var selectionStyle = UITableViewCell.SelectionStyle.blue
    var accessoryType = UITableViewCell.AccessoryType.none
    
    var detail : LabelViewModel = LabelViewModel(text: "", color: UIColor(white: 0.4, alpha: 0.8), font: UIFont(name: Commons.font.name, size: Commons.font.size.S), isHidden: true, lines: 1)
    
    var isBookmarked: Bool? = nil
    
    var title = LabelViewModel()

    var subTitle = LabelViewModel(text: "", color: .lightGray, font: UIFont(name: Commons.font.name, size: Commons.font.size.M), isHidden: false, lines: 1)

    /// convenient id
    var id: String? = nil
    
    /// thumbnail url and placeholders
    var thumbnailUrl: URL? = nil
    var placeholderImageName: String? = nil
    var placeholderImage: UIImage? = nil
    
    /// to know if the player will work or it's a webkit only play recommendation (like to play the stream in safari)
    var useWeb: Bool = false
    
    /// initialization of the view model for RT catalog audios
    init(audio: RTCatalog?) {
        id = audio?.guideId ?? audio?.presetId ?? audio?.genreId
        title.text = audio?.titleAndText() ?? ""
        subTitle.text = audio?.subtext ?? ""
        if let bitrate = audio?.bitrate {
            detail.color = UIColor(white: 0.4, alpha: 0.8)
            detail.text = "\(bitrate) Kbps"
        }
        else {
            detail.text = ""
        }
        if let currentTrack = audio?.currentTrack,
            subTitle.text != currentTrack {
                detail.text = "\(detail.text) \(currentTrack)"
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
        }
        else if titles.count == 1 {
            title.text = titles[0]
            subTitle.text = ""
            subTitle.isHidden = true
            title.lines = 3
        }
    }
    
    /// initialization of the view model for LDLA stream audios
    init(stream: Stream?) {
        id = "\(stream?.id ?? 0)"
        title.text = stream?.station?.name ?? ""
        subTitle.text = (stream?.station?.city?.name ?? "") + " " + (stream?.station?.city?.district?.name ?? "")
        detail.text = stream?.station?.tuningDial ?? ""
        
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
    
    /// initialization of the view model for LDLA stream audios
    init(desconcierto: Desconcierto?, audioUrl: String?, order: Int) {
        id = "\(desconcierto?.id ?? 0)"
        if let name = audioUrl?.components(separatedBy: "/").last?.removingPercentEncoding,
            name.contains("mp3") {
            title.text = name
        }
        else {
            title.text = "ED-\(desconcierto?.date ?? "file")-\(order).mp3"
            useWeb = true
        }
        subTitle.text = ""
        detail.text = ""
    
        placeholderImageName = Stream.placeholderImageName
        if let imageName = placeholderImageName {
            placeholderImage = UIImage.init(named: imageName)
        }

        if let urlChecked = URL(string: "http://www.eldesconcierto.com.ar/wp-content/uploads/2018/03/logo-quique-pesoa-app-200.png"),
            UIApplication.shared.canOpenURL(urlChecked) {
            thumbnailUrl = urlChecked
        }
        if let audioUrl = audioUrl,
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
        detail.text = bookmark?.detail ?? ""
        id = bookmark?.id
        placeholderImageName = bookmark?.placeholder
        if let imageName = placeholderImageName {
            placeholderImage = UIImage.init(named: imageName)
        }
        subTitle.text = bookmark?.subTitle ?? ""
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
        title.text = bookmark?.title ?? ""
        useWeb = bookmark?.useWeb ?? false
        isBookmarked = true
    }
    
    func urlString() -> String? {
        return url?.absoluteString
    }
    
    static func height() -> Float {
        return cellheight
    }
    
    /// to know if the model is in bookmark
    func checkIfBookmarked() -> Bool {
        return Bookmark.search(byUrl: url?.absoluteString) != nil
    }
    
    /// Use the url of the stream/audio as an AVURLAsset
    func urlAsset() -> AVURLAsset? {
        guard let url = url else { return nil }
        return AVURLAsset(url: url)
    }
    
}

/// RNA Station method for update
extension AudioViewModel {
    public mutating func update(station: RNAStation?, isAm: Bool) {
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
