//
//  Desconcierto+.swift
//  LDLARadio
//
//  Created by fox on 28/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import UIKit

extension Desconcierto: Modellable {

    static func all() -> [Desconcierto]? {
        return all(predicate: nil,
                   sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)])
            as? [Desconcierto]
    }
}

extension Desconcierto {
    
    var audioIdentifier: String {
        return "\(id)"
    }
    
    var titleText: String? {
        return date
    }
    
    var subTitleText: String? {
        return nil
    }
    
    var detailText: String? {
        return "El Desconcierto, de Quique Pesoa"
    }
    
    var infoText: String? {
        return nil
    }
    
    var placeholderImage: UIImage? {
        let imageName = Desconcierto.placeholderImageName
        return UIImage.init(named: imageName)
    }
    
    var portraitUrl: URL? {
        return URL(string: "http://www.eldesconcierto.com.ar/wp-content/uploads/2018/03/logo-quique-pesoa-app-200.png")
    }
}

class Desconcierto1: Desconcierto {}
class Desconcierto2: Desconcierto {}
class Desconcierto3: Desconcierto {}

extension Desconcierto1: Audible {
    var audioUrl: URL? {
        if let audioUrl = streamUrl1 {
            return URL(string: audioUrl)
        }
        return nil
    }
}

extension Desconcierto2: Audible {
    var audioUrl: URL? {
        if let audioUrl = streamUrl2 {
            return URL(string: audioUrl)
        }
        return nil
    }
}

extension Desconcierto3: Audible {
    var audioUrl: URL? {
        if let audioUrl = streamUrl3 {
            return URL(string: audioUrl)
        }
        return nil
    }
}

extension Desconcierto: Sectionable {
    var sectionIdentifier: String {
        return "\((Int(id) * 1000) + Int(arc4random()))"
    }
    
    var isCollapsed: Bool {
        false
    }
    
    var parentId: String? {
        return nil
    }
    
    var sectionDetailText: String? {
        return detailText
    }
    
    var queryUrl: URL? {
        let queryUrl = "\(RestApi.Constants.Service.ldlaServer)/desconciertos/\(id).json"
        if let urlChecked = URL(string: queryUrl) {
            return urlChecked
        }
        return nil
    }
    
    var content: ([String?], [String?]) {
        return ([], [streamUrl1, streamUrl2, streamUrl3])
    }
    
    typealias SectionModelType = String?

}
