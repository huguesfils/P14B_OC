//
//  DIContainer.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 22/04/2026.
//

import Foundation

struct DIContainer {
    let authService: AuthServiceProtocol
    let eventService: EventServiceProtocol

    init() {
        self.authService = AuthService()
        self.eventService = EventService()
    }
}
