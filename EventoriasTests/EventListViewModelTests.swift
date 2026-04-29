//
//  EventListViewModelTests.swift
//  EventoriasTests
//
//  Created by Hugues Fils Caparos on 26/04/2026.
//

import Testing
import Foundation
@testable import Eventorias

@MainActor
@Suite("EventListViewModel")
struct EventListViewModelTests {

    // MARK: - Properties

    let mockEventService: MockEventService
    let viewModel: EventListViewModel

    // MARK: - Init

    init() {
        let service = MockEventService()
        mockEventService = service
        viewModel = EventListViewModel(eventService: service)
    }

    // MARK: - Helpers

    private func makeEvent(id: String, daysFromNow: Double, title: String = "Event") -> Event {
        Event(
            id: id,
            title: title,
            description: "Description",
            date: Date().addingTimeInterval(86_400 * daysFromNow),
            location: "Paris",
            category: .conference,
            creatorId: "user-1",
            guests: []
        )
    }

    // MARK: - loadEvents Success

    @Test("Load events populates events on success")
    func loadEventsSuccess() async {
        mockEventService.events = [
            makeEvent(id: "1", daysFromNow: 1),
            makeEvent(id: "2", daysFromNow: 2)
        ]

        await viewModel.loadEvents()

        #expect(viewModel.events.count == 2)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
    }

    @Test("Load events sorts by date ascending")
    func loadEventsSortsByDateAscending() async {
        mockEventService.events = [
            makeEvent(id: "future", daysFromNow: 10, title: "Future"),
            makeEvent(id: "soon", daysFromNow: 1, title: "Soon"),
            makeEvent(id: "later", daysFromNow: 5, title: "Later")
        ]

        await viewModel.loadEvents()

        #expect(viewModel.events.map(\.id) == ["soon", "later", "future"])
    }

    @Test("Load events with empty source results in empty list")
    func loadEventsEmpty() async {
        mockEventService.events = []

        await viewModel.loadEvents()

        #expect(viewModel.events.isEmpty)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
    }

    // MARK: - loadEvents Error

    @Test("Load events sets errorMessage when service throws")
    func loadEventsServiceError() async {
        mockEventService.errorToThrow = EventoriasError.eventFetchFailed("Network down")

        await viewModel.loadEvents()

        #expect(viewModel.errorMessage == "Network down")
        #expect(viewModel.events.isEmpty)
        #expect(viewModel.isLoading == false)
    }

    @Test("Load events clears previous error on success")
    func loadEventsClearsPreviousError() async {
        mockEventService.errorToThrow = EventoriasError.eventFetchFailed("First error")
        await viewModel.loadEvents()
        #expect(viewModel.errorMessage != nil)

        mockEventService.errorToThrow = nil
        mockEventService.events = [makeEvent(id: "1", daysFromNow: 1)]
        await viewModel.loadEvents()

        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.events.count == 1)
    }

    @Test("Reload after success replaces events")
    func reloadReplacesEvents() async {
        mockEventService.events = [makeEvent(id: "1", daysFromNow: 1)]
        await viewModel.loadEvents()
        #expect(viewModel.events.count == 1)

        mockEventService.events = [
            makeEvent(id: "2", daysFromNow: 2),
            makeEvent(id: "3", daysFromNow: 3)
        ]
        await viewModel.loadEvents()

        #expect(viewModel.events.count == 2)
        #expect(viewModel.events.map(\.id) == ["2", "3"])
    }

    // MARK: - Initial State

    @Test("Initial state has empty events and no loading")
    func initialState() {
        #expect(viewModel.events.isEmpty)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
    }
}
