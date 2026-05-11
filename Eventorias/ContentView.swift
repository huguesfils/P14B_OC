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
                TabView {
                    Tab("Events", systemImage: "list.bullet") {
                        EventListView(container: container)
                    }
                    Tab("Calendar", systemImage: "calendar") {
                        EventCalendarView(container: container)
                    }
                    Tab("Profile", systemImage: "person.crop.circle") {
                        ProfileView(container: container, onSessionEnded: endSession)
                    }
                }
            } else {
                AuthenticationView(container: container, isAuthenticated: $isAuthenticated)
            }
        }
        .onAppear {
            isAuthenticated = container.authService.currentUserId != nil
        }
        .preferredColorScheme(.dark)
    }

    private func endSession() {
        isAuthenticated = false
    }
}

#Preview {
    ContentView(container: DIContainer())
}
