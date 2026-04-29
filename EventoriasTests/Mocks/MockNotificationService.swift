//
//  MockNotificationService.swift
//  EventoriasTests
//
//  Created by Hugues Fils Caparos on 26/04/2026.
//

import Foundation
@testable import Eventorias

final class MockNotificationService: NotificationServiceProtocol, @unchecked Sendable {
    var authorizationStatus: NotificationAuthorizationStatus = .notDetermined
    var requestAuthorizationResult = true
    var errorToThrow: Error?

    private(set) var scheduledEventIds: [String] = []
    private(set) var canceledEventIds: [String] = []
    private(set) var requestAuthorizationCalls = 0

    func currentAuthorizationStatus() async -> NotificationAuthorizationStatus {
        authorizationStatus
    }

    func requestAuthorization() async throws -> Bool {
        requestAuthorizationCalls += 1
        if let error = errorToThrow { throw error }
        if requestAuthorizationResult {
            authorizationStatus = .authorized
        } else {
            authorizationStatus = .denied
        }
        return requestAuthorizationResult
    }

    func scheduleReminder(for event: Event) async throws {
        if let error = errorToThrow { throw error }
        scheduledEventIds.append(event.id)
    }

    func cancelReminder(forEventId eventId: String) async {
        canceledEventIds.append(eventId)
        scheduledEventIds.removeAll { $0 == eventId }
    }
}
