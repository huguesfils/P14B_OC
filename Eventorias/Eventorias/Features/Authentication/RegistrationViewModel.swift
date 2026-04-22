//
//  RegistrationViewModel.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 09/03/2026.
//

import Foundation

@Observable
final class RegistrationViewModel {
    var email = ""
    var password = ""
    var confirmPassword = ""
    var errorMessage: String?
    var isLoading = false

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func register() async -> Bool {
        guard validateFields() else { return false }

        isLoading = true
        errorMessage = nil

        do {
            _ = try await authService.register(email: email, password: password)
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
            errorMessage = "Please enter a password"
            return false
        }
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters"
            return false
        }
        if password != confirmPassword {
            errorMessage = "Passwords do not match"
            return false
        }
        return true
    }
}
