//
//  ArchiveFile+.swift
//  LDLARadio
//
//  Created by fox on 13/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import UIKit

extension ArchiveFile {
    func urlString() -> String? {
        guard let server = detail?.server,
            let dir = detail?.dir,
            let original = original else {
                return nil
        }
        return "https://\(server)\(dir)\(original)"
    }
}

extension ArchiveFile: Audible {
    var audioIdentifier: String {
        return original ?? "#\(arc4random())"
    }
    
    var titleText: String? {
        return String.join(array: [title, detail?.doc?.title], separator: ". ")
    }
    
    var subTitleText: String? {
        return String.join(array: [detail?.doc?.creator, detail?.doc?.subject, album, artist, genre], separator: ". ")
    }
    
    var detailText: String? {
        return String.join(array: [detail?.doc?.mediaType, track, format, length], separator: ". ")
    }
    
    var infoText: String? {
        return String.join(array: [titleText, subTitleText, detailText, detail?.doc?.descript])
    }
    
    var placeholderImage: UIImage? {
        let imageName = ArchiveDoc.placeholderImageName
        return UIImage.init(named: imageName)
    }
    
    var portraitUrl: URL? {
        if let imageUrl = detail?.image?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) {
            return URL(string: imageUrl)
        }
        return nil
    }
    
    var audioUrl: URL? {
        if let audioUrl = urlString()?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) {
            return URL(string: audioUrl)
        }
        return nil
    }

}
