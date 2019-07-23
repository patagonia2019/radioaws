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
    
    var url: URL? = nil
    var thumbnailUrl: URL? = nil
    var placeholderImage: UIImage? = nil
    var detail: String
    let titleColor: UIColor = .darkGray
    let titleFont: UIFont? = UIFont(name: Commons.font.name, size: Commons.font.size)
    let subTitleColor: UIColor = .lightGray
    let subTitleFont: UIFont? = UIFont(name: Commons.font.name, size: Commons.font.size-2)
    let detailColor: UIColor = .red
    let detailFont: UIFont? = UIFont(name: Commons.font.name, size: Commons.font.size-4)
    var title: String
    var subTitle: String
    var useWeb: Bool = false

    init(audio: RTCatalog?) {
        assert(audio?.isAudio() ?? false)
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
    
    init(stationAm: RNAStation?) {
        title = stationAm?.firstName ?? ""
        subTitle = stationAm?.lastName ?? ""
        detail = stationAm?.dialAM ?? ""
        placeholderImage = UIImage.init(named: "RNA-256x256bb")
        if let uriImage = stationAm?.image,
            let urlChecked = URL(string: RestApi.Constants.Service.url(with: "/files/\(uriImage)", baseUrl: RestApi.Constants.Service.rnaServer)),
            UIApplication.shared.canOpenURL(urlChecked)
        {
            thumbnailUrl = urlChecked
        }
        if let url1 = stationAm?.url1,
            let amUri = stationAm?.amUri,
            amUri.count > 0,
            let port = stationAm?.port,
            port.count > 0,
            let urlChecked = URL(string: "http://\(url1):\(port)\(amUri)"),
            UIApplication.shared.canOpenURL(urlChecked)
        {
            url = urlChecked
        }
    }
    
    init(stationFm: RNAStation?) {
        title = stationFm?.firstName ?? ""
        subTitle = stationFm?.lastName ?? ""
        detail = stationFm?.dialFM ?? ""
        placeholderImage = UIImage.init(named: "RNA-256x256bb")
        if let uriImage = stationFm?.image,
            let urlChecked = URL(string: RestApi.Constants.Service.url(with: "/rna/\(uriImage)", baseUrl: RestApi.Constants.Service.rnaServer)),
            UIApplication.shared.canOpenURL(urlChecked)
        {
            thumbnailUrl = urlChecked
        }
        if let url1 = stationFm?.url1,
            let fmUri = stationFm?.fmUri,
            fmUri.count > 0,
            let port = stationFm?.port,
            port.count > 0,
            let urlChecked = URL(string: "http://\(url1):\(port)\(fmUri)"),
            UIApplication.shared.canOpenURL(urlChecked)
        {
            url = urlChecked
        }
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
