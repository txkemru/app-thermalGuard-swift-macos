//
//  ThermalGuardApp.swift
//  ThermalGuard
//
//  Created by Владимир Пушков on 15.07.2025.
//

import SwiftUI

@main
struct ThermalGuardApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
