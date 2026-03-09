//
//  ContentView.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 09/03/2026.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var isAuthenticated = false

    var body: some View {
        Group {
            if isAuthenticated {
                Text("Welcome to Eventorias!")
            } else {
                AuthenticationView(isAuthenticated: $isAuthenticated)
            }
        }
        .onAppear {
            isAuthenticated = Auth.auth().currentUser != nil
        }
    }
}

#Preview {
    ContentView()
}
