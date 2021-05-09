//
//  Persistence.swift
//  Shared
//
//  Created by fox on 08/05/2021.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    /// Function to obtain all the albums sorted by title
    mutating func streamsFetch() -> [Stream]? {
//        guard let context = oldContext else { fatalError() }
        let req = NSFetchRequest<Stream>(entityName: "Stream")
        req.predicate = NSPredicate(format: "listenIsWorking = true")
        req.sortDescriptors = [NSSortDescriptor(key: "station.name", ascending: true)]
        let array = try? oldContext?.fetch(req)
        return array
    }

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    /// The managed object model for the application.
    var managedObjectModel: NSManagedObjectModel? {
        guard let modelURL = Bundle.main.url(forResource: "Radio", withExtension: "momd") else {
            return nil
        }
        return NSManagedObjectModel(contentsOf: modelURL)
    }

    public func createPrivateQueueContext() throws -> NSManagedObjectContext {
        
        // Uses the same store and model, but a new persistent store coordinator and context.
        guard let managedObjectModel = managedObjectModel else { fatalError() }
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        /*
         Attempting to add a persistent store may yield an error--pass it out of
         the function for the caller to deal with.
         */
        let options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]
        
        guard let sqlitePreExistent = Bundle.main.path(forResource: Bundle.main.bundleIdentifier, ofType: "sqlite3") else {
            fatalError()
        }
        
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil,
                                           at: URL(fileURLWithPath: sqlitePreExistent), options: options)
        
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        context.performAndWait() {
            
            context.persistentStoreCoordinator = coordinator
            
            // Avoid using default merge policy in multi-threading environment:
            // when we delete (and save) a record in one context,
            // and try to save edits on the same record in the other context before merging the changes,
            // an exception will be thrown because Core Data by default uses NSErrorMergePolicy.
            // Setting a reasonable mergePolicy is a good practice to avoid that kind of exception.
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            // In OS X, a context provides an undo manager by default
            // Disable it for performance benefit
            context.undoManager = nil
        }
        
        return context
    }
    

    var container: NSPersistentCloudKitContainer {
        return NSPersistentCloudKitContainer(name: "Radio")
    }

    init(inMemory: Bool = false) {
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            

        })
    }
    
    public lazy var oldContext : NSManagedObjectContext? = {
        do {
            return try createPrivateQueueContext()
        } catch {
            fatalError("fatal: No context \(error)")
        }
    }()

}
