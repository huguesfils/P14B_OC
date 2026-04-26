//
//  ContentView.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 09/03/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = false

    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }

    var body: some View {
        Group {
            if isAuthenticated {
                EventListView(container: container, onSignOut: signOut)
            } else {
                AuthenticationView(container: container, isAuthenticated: $isAuthenticated)
            }
        }
        .onAppear {
            isAuthenticated = container.authService.currentUserId != nil
        }
    }

    private func signOut() {
        do {
            try container.authService.signOut()
            isAuthenticated = false
        } catch {
            // Sign out errors are non-recoverable locally
        }
    }
}

#Preview {
    ContentView(container: DIContainer())
}
