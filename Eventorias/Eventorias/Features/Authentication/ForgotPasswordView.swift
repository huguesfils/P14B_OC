//
//  ForgotPasswordView.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 09/03/2026.
//

import SwiftUI

struct ForgotPasswordView: View {
    @State private var email = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Text("Reset Password")
                    .font(.largeTitle)
                    .bold()

                Text("Enter your email and we'll send you a link to reset your password.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding()
                    .background(.quaternary)
                    .clipShape(.rect(cornerRadius: 10))

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }

                if let successMessage {
                    Text(successMessage)
                        .foregroundStyle(.green)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }

                Button("Send Reset Link") {
                    Task {
                        await sendReset()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading || email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func sendReset() async {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            try await authService.sendPasswordReset(email: email)
            successMessage = "Reset link sent! Check your inbox."
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

#Preview {
    ForgotPasswordView(authService: AuthService())
}
