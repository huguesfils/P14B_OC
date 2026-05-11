//
//  MockUserNotificationCenter.swift
//  EventoriasTests
//
//  Created by Hugues Fils Caparos on 11/05/2026.
//

import Foundation
import UserNotifications
@testable import Eventorias

final class MockUserNotificationCenter: UserNotificationCenterProtocol, @unchecked Sendable {
    var stubAuthorizationStatus: UNAuthorizationStatus = .notDetermined
    var requestAuthorizationResult = true
    var errorToThrow: Error?

    private(set) var addedRequests: [UNNotificationRequest] = []
    private(set) var removedIdentifiers: [String] = []
    private(set) var requestAuthorizationOptions: UNAuthorizationOptions?

    func authorizationStatus() async -> UNAuthorizationStatus {
        stubAuthorizationStatus
    }

    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        requestAuthorizationOptions = options
        if let error = errorToThrow { throw error }
        return requestAuthorizationResult
    }

    func add(_ request: UNNotificationRequest) async throws {
        if let error = errorToThrow { throw error }
        addedRequests.append(request)
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        removedIdentifiers.append(contentsOf: identifiers)
    }
}
