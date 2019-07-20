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
        static let cellheight: CGFloat = 85
        static let identifier: String = "AudioIdentifier"
    }
    
    var url: URL? = nil
    var thumbnailUrl: URL? = nil
    var detail: String
    let height: CGFloat = hardcode.cellheight
    let titleColor: UIColor = .darkGray
    let titleFont: UIFont? = UIFont(name: Commons.font.name, size: Commons.font.size)
    let subTitleColor: UIColor = .lightGray
    let subTitleFont: UIFont? = UIFont(name: Commons.font.name, size: Commons.font.size-2)
    let detailColor: UIColor = .lightText
    let detailFont: UIFont? = UIFont(name: Commons.font.name, size: Commons.font.size-4)
    var title: String
    var subTitle: String
    var useWeb: Bool = false

    init(audio: RTCatalog?) {
        assert(audio?.isAudio() ?? false)
        title = audio?.title ?? audio?.text ?? ""
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
    
    func urlAsset() -> AVURLAsset? {
        guard let playUrl = urlString()?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let streamPlaylistURL = URL(string: playUrl) else { return nil }
        print("play = \(streamPlaylistURL)")
        return AVURLAsset(url: streamPlaylistURL)
    }
    
    func urlString() -> String? {
        return url?.absoluteString
    }
    

    
}
