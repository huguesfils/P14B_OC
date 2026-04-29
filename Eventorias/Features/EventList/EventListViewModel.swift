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

    private let eventService: EventServiceProtocol

    init(eventService: EventServiceProtocol) {
        self.eventService = eventService
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
}
