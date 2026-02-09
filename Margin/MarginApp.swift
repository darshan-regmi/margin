//
//  MarginApp.swift
//  Margin
//
//  Created by Darshan Regmi on 09/02/2026.
//

import SwiftUI
import CoreData

@main
struct MarginApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
