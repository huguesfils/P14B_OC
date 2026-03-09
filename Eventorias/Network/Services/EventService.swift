//
//  EventService.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 09/03/2026.
//

import Foundation
import FirebaseFirestore

final class EventService: EventServiceProtocol, @unchecked Sendable {
    private let db = Firestore.firestore()
    private let collection = "events"

    func fetchEvents() async throws -> [Event] {
        do {
            let snapshot = try await db.collection(collection).getDocuments()
            return try snapshot.documents.map { document in
                try document.data(as: Event.self)
            }
        } catch {
            throw EventoriasError.eventFetchFailed(error.localizedDescription)
        }
    }

    func createEvent(_ event: Event) async throws {
        do {
            try db.collection(collection).document(event.id).setData(from: event)
        } catch {
            throw EventoriasError.eventCreationFailed(error.localizedDescription)
        }
    }

    func deleteEvent(_ eventId: String) async throws {
        do {
            try await db.collection(collection).document(eventId).delete()
        } catch {
            throw EventoriasError.eventDeletionFailed(error.localizedDescription)
        }
    }
}
