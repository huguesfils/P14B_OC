//
//  ProfileViewModel.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 26/04/2026.
//

import Foundation

@Observable
final class ProfileViewModel {
    var errorMessage: String?
    var isLoading = false

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    var userId: String? {
        authService.currentUserId
    }

    func signOut() -> Bool {
        errorMessage = nil
        do {
            try authService.signOut()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func deleteAccount() async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            try await authService.deleteAccount()
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
}
