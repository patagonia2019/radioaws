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
    var titleFont: UIFont? = UIFont(name: Commons.font.name, size: Commons.font.size)
    var subTitleColor: UIColor = .lightGray
    var subTitleFont: UIFont? = UIFont(name: Commons.font.name, size: Commons.font.size-2)
    var detailColor: UIColor = .red
    var detailFont: UIFont? = UIFont(name: Commons.font.name, size: Commons.font.size-4)
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
        if let currentTrack = audio?.currentTrack {
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
        
        if let uriImage = station?.image,
            uriImage.count > 0,
            let urlChecked = URL(string: RestApi.Constants.Service.url(with: "/files/\(uriImage)", baseUrl: RestApi.Constants.Service.rnaServer)),
            UIApplication.shared.canOpenURL(urlChecked)
        {
            thumbnailUrl = urlChecked
        }
        else if let uriImage = currentProgram?.imageStation,
            uriImage.count > 0,
            let urlChecked = URL(string: RestApi.Constants.Service.url(with: "/files/\(uriImage)", baseUrl: RestApi.Constants.Service.rnaServer)),
            UIApplication.shared.canOpenURL(urlChecked)
        {
            thumbnailUrl = urlChecked
        }
        else if let uriImage = currentProgram?.image,
            uriImage.count > 0,
            let urlChecked = URL(string: RestApi.Constants.Service.url(with: "/files/\(uriImage)", baseUrl: RestApi.Constants.Service.rnaServer)),
            UIApplication.shared.canOpenURL(urlChecked)
        {
            thumbnailUrl = urlChecked
        }
        
        if let url1 = station?.url1,
            let uri = isAm ? station?.amUri : station?.fmUri,
            uri.count > 0,
            let port = station?.port,
            port.count > 0,
            let urlChecked = URL(string: "http://\(url1):\(port)\(uri)"),
            UIApplication.shared.canOpenURL(urlChecked)
        {
            url = urlChecked
        }
        if let url2 = station?.url2,
            let uri = isAm ? station?.amUri : station?.fmUri,
            uri.count > 0,
            let port = station?.port,
            port.count > 0,
            let urlChecked = URL(string: "http://\(url2):\(port)\(uri)"),
            UIApplication.shared.canOpenURL(urlChecked)
        {
            url = urlChecked
        }
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
    
}
