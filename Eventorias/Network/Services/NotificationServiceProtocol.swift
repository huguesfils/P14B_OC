//
//  NotificationServiceProtocol.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 26/04/2026.
//

import Foundation

enum NotificationAuthorizationStatus: Sendable {
    case notDetermined
    case authorized
    case denied
    case provisional
    case ephemeral
}

protocol NotificationServiceProtocol: Sendable {
    func currentAuthorizationStatus() async -> NotificationAuthorizationStatus
    func requestAuthorization() async throws -> Bool
    func scheduleReminder(for event: Event) async throws
    func cancelReminder(forEventId eventId: String) async
}
