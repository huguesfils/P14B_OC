//
//  AuthenticationViewModel.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 09/03/2026.
//

import Foundation

@Observable
final class AuthenticationViewModel {
    var email = ""
    var password = ""
    var errorMessage: String?
    var isLoading = false

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func signIn() async -> Bool {
        guard validateFields() else { return false }

        isLoading = true
        errorMessage = nil

        do {
            _ = try await authService.signIn(email: email, password: password)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    private func validateFields() -> Bool {
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please enter your email"
            return false
        }
        if password.isEmpty {
            errorMessage = "Please enter your password"
            return false
        }
        return true
    }
}
