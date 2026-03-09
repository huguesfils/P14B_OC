//
//  MockAuthService.swift
//  EventoriasTests
//
//  Created by Hugues Fils Caparos on 09/03/2026.
//

import Foundation
@testable import Eventorias

final class MockAuthService: AuthServiceProtocol, @unchecked Sendable {
    var currentUserId: String? = "test-user-id"
    var errorToThrow: Error?

    func signIn(email: String, password: String) async throws -> String {
        if let error = errorToThrow { throw error }
        return currentUserId ?? "test-user-id"
    }

    func register(email: String, password: String) async throws -> String {
        if let error = errorToThrow { throw error }
        return currentUserId ?? "test-user-id"
    }

    func sendPasswordReset(email: String) async throws {
        if let error = errorToThrow { throw error }
    }

    func deleteAccount() async throws {
        if let error = errorToThrow { throw error }
        currentUserId = nil
    }

    func signOut() throws {
        if let error = errorToThrow { throw error }
        currentUserId = nil
    }
}
