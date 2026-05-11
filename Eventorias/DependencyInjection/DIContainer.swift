//
//  DIContainer.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 22/04/2026.
//

import Foundation
import UserNotifications

struct DIContainer {
    let authService: AuthServiceProtocol
    let eventService: EventServiceProtocol
    let notificationService: NotificationServiceProtocol

    init() {
        self.authService = AuthService()
        self.eventService = EventService()
        self.notificationService = LocalNotificationService(center: UNUserNotificationCenter.current())
    }
}
