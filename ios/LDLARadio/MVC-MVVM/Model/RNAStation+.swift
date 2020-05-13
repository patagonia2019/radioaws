//
//  RNAStation+.swift
//  LDLARadio
//
//  Created by fox on 23/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension RNAStation: Modellable {

    /// Function to obtain all the albums sorted by title
    static func all() -> [RNAStation]? {
        return all(predicate: nil, sortDescriptors: [NSSortDescriptor.init(key: "lastName", ascending: true)]) as? [RNAStation]
    }
}

extension RNAStation : Audible {
    var audioIdentifier: String {
        return id ?? "#\(arc4random())"
    }
    
    var titleText: String? {
        return firstName
    }
    
    var subTitleText: String? {
        return lastName
    }
    
    var infoText: String? {
        return nil
    }
    
    var placeholderImage: UIImage? {
        return UIImage.init(named: RNAStation.placeholderImageName)
    }
    
    var detailText: String? {
        fatalError()
    }
    
    var portraitUrl: URL? {
        fatalError()
    }
    
    var audioUrl: URL? {
        fatalError()
    }
    
    var detailTextAm: String? {
        return String.join(array: [dialAM, amCurrentProgram?.programName], separator: " ")
    }

    var portraitUrlAm: URL? {
        return imageUrl(usingUri: image)
            ?? imageUrl(usingUri: amCurrentProgram?.image)
            ?? imageUrl(usingUri: amCurrentProgram?.imageStation)
    }

    var audioUrlAm: URL? {
        return streamUrl(usingBaseUrl: url1, bandUri: amUri)
            ?? streamUrl(usingBaseUrl: url2, bandUri: amUri)
    }

    var detailTextFm: String? {
        return String.join(array: [dialFM, fmCurrentProgram?.programName], separator: " ")
    }
    
    var portraitUrlFm: URL? {
        return imageUrl(usingUri: image)
            ?? imageUrl(usingUri: fmCurrentProgram?.image)
            ?? imageUrl(usingUri: fmCurrentProgram?.imageStation)
    }

    var audioUrlFm: URL? {
        return streamUrl(usingBaseUrl: url1, bandUri: fmUri)
            ?? streamUrl(usingBaseUrl: url2, bandUri: fmUri)
    }

}

extension RNAStation: Searchable {

    /// Fetch an object by url
    static func search(byUrl url: String?) -> RNAStation? {
        guard let url = url else { return nil }
        guard let context = RestApi.instance.context else { fatalError() }
        let req = NSFetchRequest<RNAStation>(entityName: "RNAStation")
        req.predicate = NSPredicate(format: "url1 = %@ OR url2 = %@", url, url)
        let object = try? context.fetch(req).first
        return object
    }

    /// Returns the streams for a given name.
    static func search(byName name: String?) -> [RNAStation]? {
        guard let context = RestApi.instance.context else { fatalError() }
        guard let name = name else { return nil }
        let req = NSFetchRequest<RNAStation>(entityName: "RNAStation")
        req.predicate = NSPredicate(format: "lastName = %@ OR lastName CONTAINS[cd] %@ OR firstName = %@ OR firstName CONTAINS[cd] %@", name, name, name, name)
        let array = try? context.fetch(req)
        return array
    }
}

fileprivate extension RNAStation {
    func imageUrl(usingUri uri: String?) -> URL? {
        if let uri = uri, !uri.isEmpty,
            let urlChecked = URL(string: RestApi.Constants.Service.url(with: "/files/\(uri)", baseUrl: RestApi.Constants.Service.rnaServer)) {
            return urlChecked
        }
        return nil
    }
    
    func streamUrl(usingBaseUrl baseUrl: String?, bandUri: String?) -> URL? {
        if let baseUrl = baseUrl, !baseUrl.isEmpty,
            let bandUri = bandUri, !bandUri.isEmpty,
            let port = port, !port.isEmpty {
            return URL(string: "http://\(baseUrl):\(port)\(bandUri)")
        }
        return nil
    }

}
