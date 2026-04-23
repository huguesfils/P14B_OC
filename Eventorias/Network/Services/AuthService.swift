//
//  AuthService.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 09/03/2026.
//

import Foundation
import FirebaseAuth

final class AuthService: AuthServiceProtocol, @unchecked Sendable {
    private let auth = Auth.auth()

    var currentUserId: String? {
        auth.currentUser?.uid
    }

    func signIn(email: String, password: String) async throws -> String {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            return result.user.uid
        } catch {
            throw EventoriasError.authenticationFailed(error.localizedDescription)
        }
    }

    func register(email: String, password: String) async throws -> String {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            return result.user.uid
        } catch {
            throw EventoriasError.registrationFailed(error.localizedDescription)
        }
    }

    func sendPasswordReset(email: String) async throws {
        do {
            try await auth.sendPasswordReset(withEmail: email)
        } catch {
            throw EventoriasError.passwordResetFailed(error.localizedDescription)
        }
    }

    func deleteAccount() async throws {
        guard let user = auth.currentUser else {
            throw EventoriasError.accountDeletionFailed("No user logged in")
        }
        do {
            try await user.delete()
        } catch {
            throw EventoriasError.accountDeletionFailed(error.localizedDescription)
        }
    }

    func signOut() throws {
        do {
            try auth.signOut()
        } catch {
            throw EventoriasError.authenticationFailed(error.localizedDescription)
        }
    }
}
