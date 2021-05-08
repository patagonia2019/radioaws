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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
