//
//  EventServiceProtocol.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 09/03/2026.
//

import Foundation

protocol EventServiceProtocol: Sendable {
    func fetchEvents() async throws -> [Event]
    func createEvent(_ event: Event) async throws
    func updateEvent(_ event: Event) async throws
    func deleteEvent(_ eventId: String) async throws
}
