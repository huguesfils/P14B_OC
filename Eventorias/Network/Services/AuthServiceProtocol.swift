//
//  AuthServiceProtocol.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 09/03/2026.
//

import Foundation

protocol AuthServiceProtocol: Sendable {
    func signIn(email: String, password: String) async throws -> String
    func register(email: String, password: String) async throws -> String
    func sendPasswordReset(email: String) async throws
    func deleteAccount() async throws
    func signOut() throws
    var currentUserId: String? { get }
}
