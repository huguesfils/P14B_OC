//
//  EventoriasApp.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 09/03/2026.
//

import SwiftUI
import FirebaseCore

@main
struct EventoriasApp: App {
    let container: DIContainer

    init() {
        FirebaseApp.configure()
        container = DIContainer()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(container: container)
        }
    }
}
