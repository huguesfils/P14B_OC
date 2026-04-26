//
//  ProfileView.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 26/04/2026.
//

import SwiftUI

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    @State private var showSignOutConfirmation = false
    @State private var showDeleteConfirmation = false

    private let onSessionEnded: () -> Void

    init(container: DIContainer, onSessionEnded: @escaping () -> Void) {
        self.onSessionEnded = onSessionEnded
        self._viewModel = State(
            initialValue: ProfileViewModel(authService: container.authService)
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    LabeledContent("User ID", value: viewModel.userId ?? "—")
                }

                Section {
                    Button("Sign Out") {
                        showSignOutConfirmation = true
                    }
                }

                Section {
                    Button("Delete Account", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                    .disabled(viewModel.isLoading)
                } footer: {
                    Text("Deleting your account is permanent and cannot be undone.")
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Profile")
            .confirmationDialog(
                "Sign out of Eventorias?",
                isPresented: $showSignOutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Sign Out", role: .destructive) {
                    if viewModel.signOut() {
                        onSessionEnded()
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            .confirmationDialog(
                "Delete your account?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete Account", role: .destructive) {
                    Task {
                        let success = await viewModel.deleteAccount()
                        if success { onSessionEnded() }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone. All your data will be removed.")
            }
        }
    }
}

#Preview {
    ProfileView(container: DIContainer(), onSessionEnded: {})
}
