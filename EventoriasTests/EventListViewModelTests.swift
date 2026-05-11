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

    private func makeEvent(
        id: String,
        daysFromNow: Double,
        title: String = "Event",
        location: String = "Paris",
        category: EventCategory = .conference
    ) -> Event {
        Event(
            id: id,
            title: title,
            description: "Description",
            date: Date().addingTimeInterval(86_400 * daysFromNow),
            location: location,
            category: category,
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
        #expect(viewModel.selectedCategory == nil)
        #expect(viewModel.hasActiveFilter == false)
    }

    // MARK: - Category filter

    @Test("filteredEvents returns all events when no filter")
    func filteredEventsNoFilter() async {
        mockEventService.events = [
            makeEvent(id: "1", daysFromNow: 1, category: .conference),
            makeEvent(id: "2", daysFromNow: 2, category: .music)
        ]
        await viewModel.loadEvents()

        #expect(viewModel.filteredEvents.count == 2)
    }

    @Test("filteredEvents narrows to selected category")
    func filteredEventsByCategory() async {
        mockEventService.events = [
            makeEvent(id: "1", daysFromNow: 1, category: .conference),
            makeEvent(id: "2", daysFromNow: 2, category: .music),
            makeEvent(id: "3", daysFromNow: 3, category: .music)
        ]
        await viewModel.loadEvents()

        viewModel.selectedCategory = .music

        #expect(viewModel.filteredEvents.count == 2)
        #expect(viewModel.filteredEvents.allSatisfy { $0.category == .music })
        #expect(viewModel.hasActiveFilter)
    }

    @Test("filteredEvents returns empty when no event matches the filter")
    func filteredEventsNoMatch() async {
        mockEventService.events = [makeEvent(id: "1", daysFromNow: 1, category: .conference)]
        await viewModel.loadEvents()

        viewModel.selectedCategory = .sport

        #expect(viewModel.filteredEvents.isEmpty)
    }

    @Test("clearFilter resets the selected category")
    func clearFilterResets() async {
        mockEventService.events = [makeEvent(id: "1", daysFromNow: 1, category: .music)]
        await viewModel.loadEvents()
        viewModel.selectedCategory = .music

        viewModel.clearFilter()

        #expect(viewModel.selectedCategory == nil)
        #expect(viewModel.hasActiveFilter == false)
    }

    // MARK: - Search

    @Test("Initial searchText is empty and hasActiveSearch is false")
    func initialSearchState() {
        #expect(viewModel.searchText == "")
        #expect(viewModel.hasActiveSearch == false)
    }

    @Test("Empty or whitespace-only search returns all events")
    func searchIgnoresEmptyAndWhitespace() async {
        mockEventService.events = [
            makeEvent(id: "1", daysFromNow: 1, title: "WWDC"),
            makeEvent(id: "2", daysFromNow: 2, title: "Dub Dub")
        ]
        await viewModel.loadEvents()

        viewModel.searchText = ""
        #expect(viewModel.filteredEvents.count == 2)
        #expect(viewModel.hasActiveSearch == false)

        viewModel.searchText = "   "
        #expect(viewModel.filteredEvents.count == 2)
        #expect(viewModel.hasActiveSearch == false)
    }

    @Test("Search filters by title case-insensitively")
    func searchByTitle() async {
        mockEventService.events = [
            makeEvent(id: "1", daysFromNow: 1, title: "Swift Meetup"),
            makeEvent(id: "2", daysFromNow: 2, title: "Music Festival")
        ]
        await viewModel.loadEvents()

        viewModel.searchText = "swift"

        #expect(viewModel.filteredEvents.count == 1)
        #expect(viewModel.filteredEvents.first?.id == "1")
        #expect(viewModel.hasActiveSearch)
    }

    @Test("Search filters by location case-insensitively")
    func searchByLocation() async {
        mockEventService.events = [
            makeEvent(id: "1", daysFromNow: 1, title: "Talk", location: "Paris"),
            makeEvent(id: "2", daysFromNow: 2, title: "Talk", location: "Cupertino")
        ]
        await viewModel.loadEvents()

        viewModel.searchText = "PARIS"

        #expect(viewModel.filteredEvents.count == 1)
        #expect(viewModel.filteredEvents.first?.id == "1")
    }

    @Test("Search trims whitespace around the needle")
    func searchTrimsWhitespace() async {
        mockEventService.events = [
            makeEvent(id: "1", daysFromNow: 1, title: "WWDC"),
            makeEvent(id: "2", daysFromNow: 2, title: "Other")
        ]
        await viewModel.loadEvents()

        viewModel.searchText = "  WWDC  "

        #expect(viewModel.filteredEvents.count == 1)
        #expect(viewModel.filteredEvents.first?.id == "1")
    }

    @Test("Search combined with category filter applies both filters")
    func searchCombinedWithCategoryFilter() async {
        mockEventService.events = [
            makeEvent(id: "1", daysFromNow: 1, title: "Swift Conf", category: .conference),
            makeEvent(id: "2", daysFromNow: 2, title: "Swift Concert", category: .music),
            makeEvent(id: "3", daysFromNow: 3, title: "Other Concert", category: .music)
        ]
        await viewModel.loadEvents()

        viewModel.searchText = "swift"
        viewModel.selectedCategory = .music

        #expect(viewModel.filteredEvents.count == 1)
        #expect(viewModel.filteredEvents.first?.id == "2")
    }

    @Test("clearSearch resets searchText and disables hasActiveSearch")
    func clearSearchResets() async {
        mockEventService.events = [makeEvent(id: "1", daysFromNow: 1)]
        await viewModel.loadEvents()
        viewModel.searchText = "anything"

        viewModel.clearSearch()

        #expect(viewModel.searchText == "")
        #expect(viewModel.hasActiveSearch == false)
    }
}
