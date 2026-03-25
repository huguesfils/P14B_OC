//
//  MockEventService.swift
//  EventoriasTests
//
//  Created by Hugues Fils Caparos on 09/03/2026.
//

import Foundation
@testable import Eventorias

final class MockEventService: EventServiceProtocol, @unchecked Sendable {
    var events: [Event] = []
    var errorToThrow: Error?

    func fetchEvents() async throws -> [Event] {
        if let error = errorToThrow { throw error }
        return events
    }

    func createEvent(_ event: Event) async throws {
        if let error = errorToThrow { throw error }
        events.append(event)
    }

    func deleteEvent(_ eventId: String) async throws {
        if let error = errorToThrow { throw error }
        events.removeAll { $0.id == eventId }
    }
}
