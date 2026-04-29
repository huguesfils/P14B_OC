//
//  EventCalendarViewModel.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 26/04/2026.
//

import Foundation

@Observable
final class EventCalendarViewModel {
    var events: [Event] = []
    var selectedDate: Date = .now
    var errorMessage: String?
    var isLoading = false

    private let eventService: EventServiceProtocol
    private let calendar: Calendar

    init(eventService: EventServiceProtocol, calendar: Calendar = .current) {
        self.eventService = eventService
        self.calendar = calendar
    }

    var eventsForSelectedDate: [Event] {
        events
            .filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
            .sorted { $0.date < $1.date }
    }

    var datesWithEvents: Set<Date> {
        Set(events.map { calendar.startOfDay(for: $0.date) })
    }

    func loadEvents() async {
        isLoading = true
        errorMessage = nil

        do {
            events = try await eventService.fetchEvents()
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func hasEvents(on date: Date) -> Bool {
        datesWithEvents.contains(calendar.startOfDay(for: date))
    }
}
