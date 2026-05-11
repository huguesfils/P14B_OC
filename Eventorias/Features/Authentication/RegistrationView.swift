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
                    .foregroundStyle(.white)
                    .accessibilityAddTraits(.isHeader)

                VStack(spacing: 16) {
                    TextField("Email", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding()
                        .background(Color.evenGray)
                        .clipShape(.rect(cornerRadius: 10))
                        .foregroundStyle(.white)

                    SecureField("Password", text: $viewModel.password)
                        .textContentType(.newPassword)
                        .padding()
                        .background(Color.evenGray)
                        .clipShape(.rect(cornerRadius: 10))
                        .foregroundStyle(.white)

                    SecureField("Confirm Password", text: $viewModel.confirmPassword)
                        .textContentType(.newPassword)
                        .padding()
                        .background(Color.evenGray)
                        .clipShape(.rect(cornerRadius: 10))
                        .foregroundStyle(.white)
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
                .buttonStyle(.eventoriasPrimary)
                .disabled(viewModel.isLoading)

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.evenBlack)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .tint(Color.evenGray)
    }
}

#Preview {
    RegistrationView(container: DIContainer(), isAuthenticated: .constant(false))
}
