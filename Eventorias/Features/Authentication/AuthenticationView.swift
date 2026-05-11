//
//  AuthenticationView.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 09/03/2026.
//

import SwiftUI

struct AuthenticationView: View {
    @State private var viewModel: AuthenticationViewModel
    @Binding var isAuthenticated: Bool
    @State private var showRegistration = false
    @State private var showForgotPassword = false

    private let container: DIContainer

    init(container: DIContainer, isAuthenticated: Binding<Bool>) {
        self.container = container
        self._isAuthenticated = isAuthenticated
        self._viewModel = State(initialValue: AuthenticationViewModel(authService: container.authService))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Text("Eventorias")
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
                        .textContentType(.password)
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

                Button("Sign In") {
                    Task {
                        let success = await viewModel.signIn()
                        if success {
                            isAuthenticated = true
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)

                Button("Forgot password?") {
                    showForgotPassword = true
                }
                .font(.footnote)

                Spacer()

                Button("Don't have an account? Sign Up") {
                    showRegistration = true
                }
                .font(.footnote)
            }
            .padding()
            .sheet(isPresented: $showRegistration) {
                RegistrationView(container: container, isAuthenticated: $isAuthenticated)
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView(authService: container.authService)
            }
        }
    }
}

#Preview {
    AuthenticationView(container: DIContainer(), isAuthenticated: .constant(false))
}
