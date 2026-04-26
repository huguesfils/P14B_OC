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
    let notificationService: NotificationServiceProtocol

    init() {
        self.authService = AuthService()
        self.eventService = EventService()
        self.notificationService = LocalNotificationService()
    }
}
