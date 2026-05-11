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
    var searchText: String = ""

    private let eventService: EventServiceProtocol

    init(eventService: EventServiceProtocol) {
        self.eventService = eventService
    }

    var filteredEvents: [Event] {
        var result = events
        if let selectedCategory {
            result = result.filter { $0.category == selectedCategory }
        }
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            let needle = trimmed.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(needle) ||
                $0.location.lowercased().contains(needle)
            }
        }
        return result
    }

    var hasActiveFilter: Bool {
        selectedCategory != nil
    }

    var hasActiveSearch: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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

    func clearSearch() {
        searchText = ""
    }
}
