//
//  EventCreationViewModelTests.swift
//  EventoriasTests
//
//  Created by Hugues Fils Caparos on 22/04/2026.
//

import Testing
import Foundation
@testable import Eventorias

@MainActor
@Suite("EventCreationViewModel")
struct EventCreationViewModelTests {

    // MARK: - Properties

    let mockEventService: MockEventService
    let mockAuthService: MockAuthService
    let viewModel: EventCreationViewModel

    // MARK: - Init

    init() {
        let eventService = MockEventService()
        let authService = MockAuthService()
        mockEventService = eventService
        mockAuthService = authService
        viewModel = EventCreationViewModel(eventService: eventService, authService: authService)
    }

    // MARK: - Helpers

    private func fillValidFields() {
        viewModel.title = "Swift Meetup"
        viewModel.description = "A meetup about Swift"
        viewModel.location = "Paris"
        viewModel.date = Date().addingTimeInterval(86400) // tomorrow
        viewModel.category = .conference
    }

    // MARK: - createEvent Success

    @Test("Create event succeeds with valid fields")
    func createEventSuccess() async {
        fillValidFields()

        let success = await viewModel.createEvent()

        #expect(success)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
        #expect(mockEventService.events.count == 1)
        #expect(mockEventService.events.first?.title == "Swift Meetup")
        #expect(mockEventService.events.first?.category == .conference)
        #expect(mockEventService.events.first?.creatorId == "test-user-id")
    }

    @Test("Create event includes guests")
    func createEventIncludesGuests() async {
        fillValidFields()
        viewModel.guestEmail = "alice@test.com"
        viewModel.addGuest()
        viewModel.guestEmail = "bob@test.com"
        viewModel.addGuest()

        let success = await viewModel.createEvent()

        #expect(success)
        #expect(mockEventService.events.first?.guests.count == 2)
        #expect(mockEventService.events.first?.guests.contains("alice@test.com") == true)
    }

    @Test("Create event trims whitespace from fields")
    func createEventTrimsWhitespace() async {
        viewModel.title = "  Swift Meetup  "
        viewModel.description = "  A meetup  "
        viewModel.location = "  Paris  "
        viewModel.date = Date().addingTimeInterval(86400)

        let success = await viewModel.createEvent()

        #expect(success)
        #expect(mockEventService.events.first?.title == "Swift Meetup")
        #expect(mockEventService.events.first?.description == "A meetup")
        #expect(mockEventService.events.first?.location == "Paris")
    }

    // MARK: - createEvent Validation Errors

    @Test("Create event fails with empty title")
    func createEventEmptyTitle() async {
        fillValidFields()
        viewModel.title = ""

        let success = await viewModel.createEvent()

        #expect(!success)
        #expect(viewModel.errorMessage == "Please enter a title")
        #expect(mockEventService.events.isEmpty)
    }

    @Test("Create event fails with whitespace-only title")
    func createEventWhitespaceTitle() async {
        fillValidFields()
        viewModel.title = "   " // whitespace only

        let success = await viewModel.createEvent()

        #expect(!success)
        #expect(viewModel.errorMessage == "Please enter a title")
    }

    @Test("Create event fails with empty description")
    func createEventEmptyDescription() async {
        fillValidFields()
        viewModel.description = ""

        let success = await viewModel.createEvent()

        #expect(!success)
        #expect(viewModel.errorMessage == "Please enter a description")
    }

    @Test("Create event fails with empty location")
    func createEventEmptyLocation() async {
        fillValidFields()
        viewModel.location = ""

        let success = await viewModel.createEvent()

        #expect(!success)
        #expect(viewModel.errorMessage == "Please enter a location")
    }

    @Test("Create event fails with past date")
    func createEventPastDate() async {
        fillValidFields()
        viewModel.date = Date().addingTimeInterval(-3600) // 1 hour ago

        let success = await viewModel.createEvent()

        #expect(!success)
        #expect(viewModel.errorMessage == "Event date must be in the future")
    }

    // MARK: - createEvent Auth Error

    @Test("Create event fails when not authenticated")
    func createEventNotAuthenticated() async {
        fillValidFields()
        mockAuthService.currentUserId = nil

        let success = await viewModel.createEvent()

        #expect(!success)
        #expect(viewModel.errorMessage == "You must be logged in to create an event")
        #expect(mockEventService.events.isEmpty)
    }

    // MARK: - createEvent Service Error

    @Test("Create event fails when service throws")
    func createEventServiceError() async {
        fillValidFields()
        mockEventService.errorToThrow = EventoriasError.eventCreationFailed("Network error")

        let success = await viewModel.createEvent()

        #expect(!success)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLoading == false)
        #expect(mockEventService.events.isEmpty)
    }

    // MARK: - addGuest

    @Test("Add guest with valid email")
    func addGuestValid() {
        viewModel.guestEmail = "alice@test.com"

        viewModel.addGuest()

        #expect(viewModel.guests == ["alice@test.com"])
        #expect(viewModel.guestEmail.isEmpty)
    }

    @Test("Add guest lowercases email")
    func addGuestLowercases() {
        viewModel.guestEmail = "Alice@Test.COM"

        viewModel.addGuest()

        #expect(viewModel.guests == ["alice@test.com"])
    }

    @Test("Add guest trims whitespace")
    func addGuestTrimsWhitespace() {
        viewModel.guestEmail = "  alice@test.com  "

        viewModel.addGuest()

        #expect(viewModel.guests == ["alice@test.com"])
    }

    @Test("Add guest ignores empty email")
    func addGuestEmptyEmail() {
        viewModel.guestEmail = ""

        viewModel.addGuest()

        #expect(viewModel.guests.isEmpty)
    }

    @Test("Add guest ignores email without @")
    func addGuestInvalidEmail() {
        viewModel.guestEmail = "not-an-email"

        viewModel.addGuest()

        #expect(viewModel.guests.isEmpty)
    }

    @Test("Add guest ignores duplicate email")
    func addGuestDuplicate() {
        viewModel.guestEmail = "alice@test.com"
        viewModel.addGuest()
        viewModel.guestEmail = "alice@test.com"

        viewModel.addGuest()

        #expect(viewModel.guests.count == 1)
    }

    // MARK: - removeGuest

    @Test("Remove guest removes the correct email")
    func removeGuest() {
        viewModel.guestEmail = "alice@test.com"
        viewModel.addGuest()
        viewModel.guestEmail = "bob@test.com"
        viewModel.addGuest()

        viewModel.removeGuest("alice@test.com")

        #expect(viewModel.guests == ["bob@test.com"])
    }

    @Test("Remove guest with unknown email does nothing")
    func removeGuestUnknown() {
        viewModel.guestEmail = "alice@test.com"
        viewModel.addGuest()

        viewModel.removeGuest("nobody@test.com")

        #expect(viewModel.guests.count == 1)
    }
}
