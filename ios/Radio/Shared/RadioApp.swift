//
//  RadioApp.swift
//  Shared
//
//  Created by fox on 08/05/2021.
//

import SwiftUI

@main
struct RadioApp: App {
    let persistenceController = PersistenceController.shared
    let dataImportor = DataImporter(persistentContainer: PersistenceController.shared.container)

    var body: some Scene {
        WindowGroup {
            RadioTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
