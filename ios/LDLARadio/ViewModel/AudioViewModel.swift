//
//  AudioViewModel.swift
//  LDLARadio
//
//  Created by fox on 15/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
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
    
    var titleColor: UIColor = .darkGray
    var titleFont: UIFont? = UIFont(name: Commons.font.name, size: Commons.font.size.L)
    var subTitleColor: UIColor = .lightGray
    var subTitleFont: UIFont? = UIFont(name: Commons.font.name, size: Commons.font.size.M)
    var detailColor: UIColor = UIColor(white: 0.4, alpha: 0.8)
    var detailFont: UIFont? = UIFont(name: Commons.font.name, size: Commons.font.size.S)
    var id: String? = nil
    var url: URL? = nil
    var thumbnailUrl: URL? = nil
    var placeholderImage: UIImage? = nil
    var title: String = ""
    var subTitle: String = ""
    var detail: String = ""
    var useWeb: Bool = false

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
        
    }
    
    init(stream: Stream?) {
        id = "\(stream?.id ?? 0)"
        title = stream?.station?.name ?? ""
        subTitle = stream?.station?.city?.name ?? ""
        detail = stream?.station?.city?.district?.name ?? ""
        if let imageUrl = stream?.station?.imageUrl,
            let urlChecked = URL(string: imageUrl),
            UIApplication.shared.canOpenURL(urlChecked) {
            thumbnailUrl = urlChecked
        }
        if let audioUrl = stream?.name,
            let urlChecked = URL(string: audioUrl),
            UIApplication.shared.canOpenURL(urlChecked) {
            url = urlChecked
        }
    }
    
    
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
        placeholderImage = UIImage.init(named: "RNA-256x256bb")
        
        thumbnailUrl = imageUrl(usingUri: station?.image)
            ?? imageUrl(usingUri: currentProgram?.image)
            ?? imageUrl(usingUri: currentProgram?.imageStation)
        
        url = streamUrl(usingBaseUrl: station?.url1, port: station?.port, bandUri: isAm ? station?.amUri : station?.fmUri)
            ?? streamUrl(usingBaseUrl: station?.url2, port: station?.port, bandUri: isAm ? station?.amUri : station?.fmUri)
    }
    
    init(stationAm: RNAStation?) {
        update(station: stationAm, isAm: true)
    }
    
    init(stationFm: RNAStation?) {
        update(station: stationFm, isAm: false)
    }
    
    func urlAsset() -> AVURLAsset? {
        guard let playUrl = urlString()?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let streamPlaylistURL = URL(string: playUrl) else { return nil }
        print("play = \(streamPlaylistURL)")
        return AVURLAsset(url: streamPlaylistURL)
    }
    
    func urlString() -> String? {
        return url?.absoluteString
    }
    
    static func height() -> Float {
        return hardcode.cellheight
    }
    
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
