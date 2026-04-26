//
//  EventDetailViewModel.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 26/04/2026.
//

import Foundation

@Observable
final class EventDetailViewModel {
    private(set) var event: Event
    var isEditing = false
    var errorMessage: String?
    var isLoading = false

    var title: String
    var description: String
    var date: Date
    var location: String
    var category: EventCategory
    var guests: [String]
    var guestEmail = ""

    private let eventService: EventServiceProtocol
    private let authService: AuthServiceProtocol

    init(event: Event, eventService: EventServiceProtocol, authService: AuthServiceProtocol) {
        self.event = event
        self.eventService = eventService
        self.authService = authService
        self.title = event.title
        self.description = event.description
        self.date = event.date
        self.location = event.location
        self.category = event.category
        self.guests = event.guests
    }

    var canEdit: Bool {
        event.creatorId == authService.currentUserId
    }

    func startEditing() {
        resetEditableFields()
        isEditing = true
        errorMessage = nil
    }

    func cancelEditing() {
        resetEditableFields()
        isEditing = false
        errorMessage = nil
    }

    func saveChanges() async -> Bool {
        guard validateFields() else { return false }

        isLoading = true
        errorMessage = nil

        let updated = Event(
            id: event.id,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            date: date,
            location: location.trimmingCharacters(in: .whitespacesAndNewlines),
            category: category,
            creatorId: event.creatorId,
            guests: guests
        )

        do {
            try await eventService.updateEvent(updated)
            event = updated
            isEditing = false
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func deleteEvent() async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            try await eventService.deleteEvent(event.id)
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

    private func resetEditableFields() {
        title = event.title
        description = event.description
        date = event.date
        location = event.location
        category = event.category
        guests = event.guests
        guestEmail = ""
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
