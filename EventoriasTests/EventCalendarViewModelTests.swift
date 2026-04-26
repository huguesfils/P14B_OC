//
//  EventCalendarViewModelTests.swift
//  EventoriasTests
//
//  Created by Hugues Fils Caparos on 26/04/2026.
//

import Testing
import Foundation
@testable import Eventorias

@MainActor
@Suite("EventCalendarViewModel")
struct EventCalendarViewModelTests {

    // MARK: - Properties

    let mockEventService: MockEventService
    let viewModel: EventCalendarViewModel
    let calendar: Calendar
    let referenceDate: Date

    // MARK: - Init

    init() {
        // Fixed reference date to make tests deterministic regardless of clock.
        var components = DateComponents()
        components.year = 2026
        components.month = 5
        components.day = 15
        components.hour = 10
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: components) ?? Date()

        let service = MockEventService()
        mockEventService = service
        self.calendar = calendar
        self.referenceDate = date
        viewModel = EventCalendarViewModel(eventService: service, calendar: calendar)
        viewModel.selectedDate = date
    }

    // MARK: - Helpers

    private func makeEvent(id: String, hourOffset: Int, dayOffset: Int = 0, title: String = "Event") -> Event {
        let date = calendar.date(
            byAdding: .day,
            value: dayOffset,
            to: referenceDate
        ).flatMap {
            calendar.date(byAdding: .hour, value: hourOffset, to: $0)
        } ?? referenceDate
        return Event(
            id: id,
            title: title,
            description: "Description",
            date: date,
            location: "Paris",
            category: .conference,
            creatorId: "user-1",
            guests: []
        )
    }

    // MARK: - loadEvents

    @Test("Initial state is empty and not loading")
    func initialState() {
        #expect(viewModel.events.isEmpty)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
    }

    @Test("loadEvents populates events on success")
    func loadEventsSuccess() async {
        mockEventService.events = [
            makeEvent(id: "1", hourOffset: 0),
            makeEvent(id: "2", hourOffset: 0, dayOffset: 1)
        ]

        await viewModel.loadEvents()

        #expect(viewModel.events.count == 2)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
    }

    @Test("loadEvents sets errorMessage when service throws")
    func loadEventsError() async {
        mockEventService.errorToThrow = EventoriasError.eventFetchFailed("Boom")

        await viewModel.loadEvents()

        #expect(viewModel.errorMessage == "Boom")
        #expect(viewModel.events.isEmpty)
        #expect(viewModel.isLoading == false)
    }

    // MARK: - eventsForSelectedDate

    @Test("eventsForSelectedDate returns only same-day events")
    func eventsForSelectedDateSameDay() async {
        mockEventService.events = [
            makeEvent(id: "today-1", hourOffset: 0),
            makeEvent(id: "today-2", hourOffset: 4),
            makeEvent(id: "tomorrow", hourOffset: 0, dayOffset: 1),
            makeEvent(id: "yesterday", hourOffset: 0, dayOffset: -1)
        ]
        await viewModel.loadEvents()

        let ids = viewModel.eventsForSelectedDate.map(\.id)
        #expect(ids.contains("today-1"))
        #expect(ids.contains("today-2"))
        #expect(!ids.contains("tomorrow"))
        #expect(!ids.contains("yesterday"))
    }

    @Test("eventsForSelectedDate sorts by date ascending")
    func eventsForSelectedDateSorted() async {
        mockEventService.events = [
            makeEvent(id: "late", hourOffset: 6, title: "Late"),
            makeEvent(id: "early", hourOffset: 1, title: "Early"),
            makeEvent(id: "mid", hourOffset: 3, title: "Mid")
        ]
        await viewModel.loadEvents()

        #expect(viewModel.eventsForSelectedDate.map(\.id) == ["early", "mid", "late"])
    }

    @Test("eventsForSelectedDate is empty when no event on that day")
    func eventsForSelectedDateEmpty() async {
        mockEventService.events = [makeEvent(id: "tomorrow", hourOffset: 0, dayOffset: 1)]
        await viewModel.loadEvents()

        #expect(viewModel.eventsForSelectedDate.isEmpty)
    }

    @Test("Changing selectedDate updates eventsForSelectedDate")
    func changingSelectedDate() async {
        mockEventService.events = [
            makeEvent(id: "today", hourOffset: 0),
            makeEvent(id: "in-3-days", hourOffset: 0, dayOffset: 3)
        ]
        await viewModel.loadEvents()

        if let newDate = calendar.date(byAdding: .day, value: 3, to: referenceDate) {
            viewModel.selectedDate = newDate
        }

        #expect(viewModel.eventsForSelectedDate.map(\.id) == ["in-3-days"])
    }

    // MARK: - hasEvents

    @Test("hasEvents returns true for a day with events")
    func hasEventsTrue() async {
        mockEventService.events = [makeEvent(id: "1", hourOffset: 0)]
        await viewModel.loadEvents()

        #expect(viewModel.hasEvents(on: referenceDate))
    }

    @Test("hasEvents returns false for a day without events")
    func hasEventsFalse() async {
        mockEventService.events = [makeEvent(id: "1", hourOffset: 0)]
        await viewModel.loadEvents()

        if let other = calendar.date(byAdding: .day, value: 5, to: referenceDate) {
            #expect(!viewModel.hasEvents(on: other))
        }
    }

    @Test("hasEvents ignores time component within a day")
    func hasEventsIgnoresTime() async {
        mockEventService.events = [makeEvent(id: "1", hourOffset: 2)]
        await viewModel.loadEvents()

        if let sameDayDifferentHour = calendar.date(byAdding: .hour, value: 8, to: referenceDate) {
            #expect(viewModel.hasEvents(on: sameDayDifferentHour))
        }
    }
}
