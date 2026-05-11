//
//  RegistrationView.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 09/03/2026.
//

import SwiftUI

struct RegistrationView: View {
    @State private var viewModel: RegistrationViewModel
    @Binding var isAuthenticated: Bool
    @Environment(\.dismiss) private var dismiss

    init(container: DIContainer, isAuthenticated: Binding<Bool>) {
        self._isAuthenticated = isAuthenticated
        self._viewModel = State(initialValue: RegistrationViewModel(authService: container.authService))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Text("Create Account")
                    .font(.largeTitle)
                    .bold()
                    .accessibilityAddTraits(.isHeader)

                VStack(spacing: 16) {
                    TextField("Email", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding()
                        .background(.quaternary)
                        .clipShape(.rect(cornerRadius: 10))

                    SecureField("Password", text: $viewModel.password)
                        .textContentType(.newPassword)
                        .padding()
                        .background(.quaternary)
                        .clipShape(.rect(cornerRadius: 10))

                    SecureField("Confirm Password", text: $viewModel.confirmPassword)
                        .textContentType(.newPassword)
                        .padding()
                        .background(.quaternary)
                        .clipShape(.rect(cornerRadius: 10))
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }

                Button("Sign Up") {
                    Task {
                        let success = await viewModel.register()
                        if success {
                            isAuthenticated = true
                            dismiss()
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)

                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    RegistrationView(container: DIContainer(), isAuthenticated: .constant(false))
}
