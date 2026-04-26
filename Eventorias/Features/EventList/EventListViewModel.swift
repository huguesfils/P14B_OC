//
//  EventListViewModel.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 26/04/2026.
//

import Foundation

@Observable
final class EventListViewModel {
    var events: [Event] = []
    var errorMessage: String?
    var isLoading = false
    var selectedCategory: EventCategory?

    private let eventService: EventServiceProtocol

    init(eventService: EventServiceProtocol) {
        self.eventService = eventService
    }

    var filteredEvents: [Event] {
        guard let selectedCategory else { return events }
        return events.filter { $0.category == selectedCategory }
    }

    var hasActiveFilter: Bool {
        selectedCategory != nil
    }

    func loadEvents() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetched = try await eventService.fetchEvents()
            events = fetched.sorted { $0.date < $1.date }
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func clearFilter() {
        selectedCategory = nil
    }
}
