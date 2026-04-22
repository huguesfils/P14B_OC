//
//  EventCreationViewModel.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 22/04/2026.
//

import Foundation

@Observable
final class EventCreationViewModel {
    var title = ""
    var description = ""
    var date = Date()
    var location = ""
    var category: EventCategory = .other
    var guestEmail = ""
    var guests: [String] = []
    var errorMessage: String?
    var isLoading = false

    private let eventService: EventServiceProtocol
    private let authService: AuthServiceProtocol

    init(eventService: EventServiceProtocol, authService: AuthServiceProtocol) {
        self.eventService = eventService
        self.authService = authService
    }

    func createEvent() async -> Bool {
        guard validateFields() else { return false }

        guard let creatorId = authService.currentUserId else {
            errorMessage = "You must be logged in to create an event"
            return false
        }

        isLoading = true
        errorMessage = nil

        let event = Event(
            id: UUID().uuidString,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            date: date,
            location: location.trimmingCharacters(in: .whitespacesAndNewlines),
            category: category,
            creatorId: creatorId,
            guests: guests
        )

        do {
            try await eventService.createEvent(event)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func addGuest() {
        let email = guestEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !email.isEmpty, email.contains("@"), !guests.contains(email) else {
            return
        }
        guests.append(email)
        guestEmail = ""
    }

    func removeGuest(_ email: String) {
        guests.removeAll { $0 == email }
    }

    private func validateFields() -> Bool {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please enter a title"
            return false
        }
        if description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please enter a description"
            return false
        }
        if location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please enter a location"
            return false
        }
        if date < Date() {
            errorMessage = "Event date must be in the future"
            return false
        }
        return true
    }
}
