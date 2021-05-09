//
//  RadioTabView.swift
//  Radio
//
//  Created by fox on 08/05/2021.
//

import SwiftUI

struct RadioTabView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var selection = 0

    var body: some View {

        TabView {
            ContentView()
                .tabItem {
                    Image(systemName: "1.square.fill")
                    Text("First")
                }
            Text("Another Tab")
                .tabItem {
                    Image(systemName: "2.square.fill")
                    Text("Second")
                }
            Text("The Last Tab")
                .tabItem {
                    Image(systemName: "3.square.fill")
                    Text("Third")
                }
        }
        .font(.headline)
    }
}


struct RadioTabView_Previews: PreviewProvider {
    static var previews: some View {
        RadioTabView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
