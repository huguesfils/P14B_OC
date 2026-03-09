//
//  ServiceFactory.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 09/03/2026.
//

import Foundation

final class ServiceFactory: Sendable {
    static let shared = ServiceFactory()

    nonisolated let authService: AuthServiceProtocol

    private init() {
        self.authService = AuthService()
    }

    #if DEBUG
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    #endif
}
