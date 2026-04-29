//
//  ContentView.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 09/03/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var showCreateEvent = false

    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }

    var body: some View {
        Group {
            if isAuthenticated {
                NavigationStack {
                    VStack(spacing: 24) {
                        Spacer()
                        Text("Welcome to Eventorias!")
                            .font(.title)
                        Spacer()
                        Button("Sign Out", role: .destructive) {
                            signOut()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.bottom, 40)
                    }
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button("New Event", systemImage: "plus") {
                                showCreateEvent = true
                            }
                        }
                    }
                    .sheet(isPresented: $showCreateEvent) {
                        EventCreationView(container: container)
                    }
                }
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
