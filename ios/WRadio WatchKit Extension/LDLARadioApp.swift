//
//  LDLARadioApp.swift
//  WRadio WatchKit Extension
//
//  Created by fox on 08/05/2021.
//  Copyright © 2021 Mobile Patagonia. All rights reserved.
//

import SwiftUI

@main
struct LDLARadioApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
