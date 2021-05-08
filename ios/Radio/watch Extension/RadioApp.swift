//
//  RadioApp.swift
//  watch Extension
//
//  Created by fox on 08/05/2021.
//

import SwiftUI

@main
struct RadioApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
