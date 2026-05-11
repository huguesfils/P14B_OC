//
//  LocalNotificationService.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 26/04/2026.
//

import Foundation
import UserNotifications

final class LocalNotificationService: NotificationServiceProtocol, @unchecked Sendable {
    private let center: UserNotificationCenterProtocol
    private let reminderLeadTime: TimeInterval

    init(center: UserNotificationCenterProtocol, reminderLeadTime: TimeInterval = 3600) {
        self.center = center
        self.reminderLeadTime = reminderLeadTime
    }

    func currentAuthorizationStatus() async -> NotificationAuthorizationStatus {
        Self.map(await center.authorizationStatus())
    }

    func requestAuthorization() async throws -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            throw EventoriasError.unknown(error.localizedDescription)
        }
    }

    func scheduleReminder(for event: Event) async throws {
        let triggerDate = event.date.addingTimeInterval(-reminderLeadTime)
        guard triggerDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = event.title
        content.body = "Starting soon at \(event.location)"
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: triggerDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: event.id,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            throw EventoriasError.unknown(error.localizedDescription)
        }
    }

    func cancelReminder(forEventId eventId: String) async {
        center.removePendingNotificationRequests(withIdentifiers: [eventId])
    }

    private static func map(_ status: UNAuthorizationStatus) -> NotificationAuthorizationStatus {
        switch status {
        case .notDetermined: .notDetermined
        case .authorized: .authorized
        case .denied: .denied
        case .provisional: .provisional
        case .ephemeral: .ephemeral
        @unknown default: .notDetermined
        }
    }
}
