//
//  NotificationServiceProtocol.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 26/04/2026.
//

import Foundation
import UserNotifications

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

protocol UserNotificationCenterProtocol: Sendable {
    func authorizationStatus() async -> UNAuthorizationStatus
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
    func add(_ request: UNNotificationRequest) async throws
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
}

extension UNUserNotificationCenter: UserNotificationCenterProtocol {
    func authorizationStatus() async -> UNAuthorizationStatus {
        await notificationSettings().authorizationStatus
    }
}
