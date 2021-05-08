//
//  Quote+.swift
//  LDLARadio
//
//  Created by fox on 12/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation

extension Quote: Modellable {

    /// Function to obtain all the quotes
    static func all() -> [Quote]? {
        return all(predicate: nil,
                   sortDescriptors: nil)
            as? [Quote]
    }

}

extension Quote {

    /// Converstion between json file into a Dictionary
    private static func fromJsonFile(name: String) -> [[String: Any]]? {
        // Parse and insert media
        if let path = Bundle.main.path(forResource: name, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                return jsonResponse as? [[String: Any]]
            } catch {
                Log.error("error: %@", error.localizedDescription)
            }
        }
        return nil
    }

    /// Create the instances using a json file
    private static func create() {
        do {
            guard let array = fromJsonFile(name: "quotes2"),
                let context = RestApi.instance.context else {
                return
            }
            for obj in array {
                _ = try object(withEntityName: "Quote", fromJSONDictionary: obj, inContext: context)
            }
            try context.save()
        } catch {
            Log.error("error: %@", error.localizedDescription)
        }
    }

    /// Use a quote randomly
    private static func queryRandomly() -> Quote? {
        let array = all()
        let n = array?.count ?? 0
        if n == 0 {
            return nil
        }
        let rnd = Int(arc4random() % UInt32(n))
        return array?[rnd]
    }

    /// Returns or creates a quote
    private static func random() -> Quote? {
        if let quote = queryRandomly() {
            return quote
        }
        create()
        return queryRandomly()
    }

    /// Show the quote as string
    static func randomQuote() -> String {
        guard let quote = random(),
            let text = quote.text else {
            return "If you spend your whole life waiting for the storm, you'll never enjoy the sunshine.\n~Morris West"
        }
        return "\(text)\n~\(quote.author ?? "")"
    }
}
