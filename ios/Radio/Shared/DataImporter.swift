//
//  DataImporter.swift
//  Radio
//
//  Created by fox on 09/05/2021.
//

import CoreData
import Combine

class DataImporter {
    let importContext: NSManagedObjectContext
    var bag = Set<AnyCancellable>()

    init(persistentContainer: NSPersistentContainer) {
        importContext = persistentContainer.newBackgroundContext()
        importContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        runImport()
    }
    
    var versionToken: String? {
        get { UserDefaults.standard.string(forKey: "DataImporter.versionToken") }
        set { UserDefaults.standard.set(newValue, forKey: "DataImporter.versionToken") }
    }
    
    func runImport() {
        // 1. Build the correct URL
        var url = URL(string: "https://api.jsonbin.io/b/609741957a19ef1245a5de33/3")!
//        if let versionToken = self.versionToken {
//            url.appendPathComponent(versionToken)
//        }
        
        let sharedPublisher = URLSession.shared
            .dataTaskPublisher(for: url)
            .share()

        let cancellable = sharedPublisher
            .map(\.data)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("something went wrong: \(error)")
                }
                else {
                    print("\(completion)")
                }
            },
            receiveValue: { [weak self] data in
                guard let self = self
                else { return }
                
                self.importContext.perform {
                    do {
                        // 2. Decode the response
                        let response = try self.decoder.decode(StreamResponse.self, from: data)
                        
                        // 3. Store the version token
                        self.versionToken = response.versionToken
                        
                        do {
                            // 6. Finish import by calling save() on the import context
                            try self.importContext.save()
                        } catch {
                            print("Something went wrong: \(error)")
                        }
                    } catch {
                        print("Failed to decode json: \(error)")
                    }
                }
                
            }).store(in: &bag) // store the returned cancellable in a property on `DataImporter`
    }
    
    lazy var decoder: JSONDecoder = {
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      decoder.userInfo[.managedObjectContext] = importContext
      return decoder
    }()

}

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}

