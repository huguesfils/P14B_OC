//
//  EventDetailViewModelTests.swift
//  EventoriasTests
//
//  Created by Hugues Fils Caparos on 26/04/2026.
//

import Testing
import Foundation
@testable import Eventorias

@MainActor
@Suite("EventDetailViewModel")
struct EventDetailViewModelTests {

    // MARK: - Properties

    let mockEventService: MockEventService
    let mockAuthService: MockAuthService
    let originalEvent: Event
    let viewModel: EventDetailViewModel

    // MARK: - Init

    init() {
        let eventService = MockEventService()
        let authService = MockAuthService()
        let event = Event(
            id: "event-1",
            title: "Swift Meetup",
            description: "A meetup about Swift",
            date: Date().addingTimeInterval(86_400),
            location: "Paris",
            category: .conference,
            creatorId: "test-user-id",
            guests: ["alice@test.com"]
        )
        eventService.events = [event]
        mockEventService = eventService
        mockAuthService = authService
        originalEvent = event
        viewModel = EventDetailViewModel(
            event: event,
            eventService: eventService,
            authService: authService
        )
    }

    // MARK: - Init / canEdit

    @Test("Initial state mirrors event fields")
    func initialState() {
        #expect(viewModel.event.id == "event-1")
        #expect(viewModel.title == "Swift Meetup")
        #expect(viewModel.description == "A meetup about Swift")
        #expect(viewModel.location == "Paris")
        #expect(viewModel.category == .conference)
        #expect(viewModel.guests == ["alice@test.com"])
        #expect(viewModel.isEditing == false)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("canEdit is true when current user is the creator")
    func canEditWhenCreator() {
        #expect(viewModel.canEdit)
    }

    @Test("canEdit is false when current user is not the creator")
    func canEditWhenNotCreator() {
        mockAuthService.currentUserId = "another-user"
        #expect(!viewModel.canEdit)
    }

    @Test("canEdit is false when not authenticated")
    func canEditWhenNotAuthenticated() {
        mockAuthService.currentUserId = nil
        #expect(!viewModel.canEdit)
    }

    // MARK: - startEditing / cancelEditing

    @Test("startEditing enters edit mode and clears error")
    func startEditingEntersEditMode() {
        viewModel.errorMessage = "previous"
        viewModel.startEditing()
        #expect(viewModel.isEditing)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("cancelEditing restores fields and exits edit mode")
    func cancelEditingRestoresFields() {
        viewModel.startEditing()
        viewModel.title = "Changed"
        viewModel.location = "Berlin"
        viewModel.guestEmail = "x@y.com"

        viewModel.cancelEditing()

        #expect(viewModel.isEditing == false)
        #expect(viewModel.title == "Swift Meetup")
        #expect(viewModel.location == "Paris")
        #expect(viewModel.guestEmail.isEmpty)
    }

    // MARK: - saveChanges Success

    @Test("saveChanges updates event and exits edit mode")
    func saveChangesSuccess() async {
        viewModel.startEditing()
        viewModel.title = "Updated Title"
        viewModel.location = "Lyon"

        let success = await viewModel.saveChanges()

        #expect(success)
        #expect(viewModel.isEditing == false)
        #expect(viewModel.event.title == "Updated Title")
        #expect(viewModel.event.location == "Lyon")
        #expect(viewModel.errorMessage == nil)
        #expect(mockEventService.events.first?.title == "Updated Title")
    }

    @Test("saveChanges trims whitespace")
    func saveChangesTrimsWhitespace() async {
        viewModel.startEditing()
        viewModel.title = "  Padded  "
        viewModel.description = "  desc  "
        viewModel.location = "  here  "

        let success = await viewModel.saveChanges()

        #expect(success)
        #expect(viewModel.event.title == "Padded")
        #expect(viewModel.event.description == "desc")
        #expect(viewModel.event.location == "here")
    }

    @Test("saveChanges preserves id and creatorId")
    func saveChangesPreservesIdentity() async {
        viewModel.startEditing()
        viewModel.title = "New"

        _ = await viewModel.saveChanges()

        #expect(viewModel.event.id == originalEvent.id)
        #expect(viewModel.event.creatorId == originalEvent.creatorId)
    }

    // MARK: - saveChanges Validation

    @Test("saveChanges fails with empty title")
    func saveChangesEmptyTitle() async {
        viewModel.startEditing()
        viewModel.title = "   "

        let success = await viewModel.saveChanges()

        #expect(!success)
        #expect(viewModel.errorMessage == "Please enter a title")
        #expect(viewModel.isEditing)
    }

    @Test("saveChanges fails with empty description")
    func saveChangesEmptyDescription() async {
        viewModel.startEditing()
        viewModel.description = ""

        let success = await viewModel.saveChanges()

        #expect(!success)
        #expect(viewModel.errorMessage == "Please enter a description")
    }

    @Test("saveChanges fails with empty location")
    func saveChangesEmptyLocation() async {
        viewModel.startEditing()
        viewModel.location = ""

        let success = await viewModel.saveChanges()

        #expect(!success)
        #expect(viewModel.errorMessage == "Please enter a location")
    }

    @Test("saveChanges fails with past date")
    func saveChangesPastDate() async {
        viewModel.startEditing()
        viewModel.date = Date().addingTimeInterval(-3_600)

        let success = await viewModel.saveChanges()

        #expect(!success)
        #expect(viewModel.errorMessage == "Event date must be in the future")
    }

    // MARK: - saveChanges Service Error

    @Test("saveChanges fails when service throws")
    func saveChangesServiceError() async {
        viewModel.startEditing()
        viewModel.title = "Changed"
        mockEventService.errorToThrow = EventoriasError.eventUpdateFailed("Server down")

        let success = await viewModel.saveChanges()

        #expect(!success)
        #expect(viewModel.errorMessage == "Server down")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.event.title == "Swift Meetup") // unchanged
    }

    // MARK: - deleteEvent

    @Test("deleteEvent succeeds and removes from service")
    func deleteEventSuccess() async {
        let success = await viewModel.deleteEvent()

        #expect(success)
        #expect(mockEventService.events.isEmpty)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
    }

    @Test("deleteEvent fails when service throws")
    func deleteEventServiceError() async {
        mockEventService.errorToThrow = EventoriasError.eventDeletionFailed("Forbidden")

        let success = await viewModel.deleteEvent()

        #expect(!success)
        #expect(viewModel.errorMessage == "Forbidden")
        #expect(viewModel.isLoading == false)
        #expect(mockEventService.events.count == 1) // still there
    }

    // MARK: - Guests

    @Test("addGuest appends a valid email and clears input")
    func addGuestValid() {
        viewModel.guestEmail = "bob@test.com"
        viewModel.addGuest()
        #expect(viewModel.guests == ["alice@test.com", "bob@test.com"])
        #expect(viewModel.guestEmail.isEmpty)
    }

    @Test("addGuest ignores invalid email")
    func addGuestInvalid() {
        viewModel.guestEmail = "invalid"
        viewModel.addGuest()
        #expect(viewModel.guests == ["alice@test.com"])
    }

    @Test("addGuest ignores duplicates")
    func addGuestDuplicate() {
        viewModel.guestEmail = "alice@test.com"
        viewModel.addGuest()
        #expect(viewModel.guests.count == 1)
    }

    @Test("removeGuest removes matching email")
    func removeGuest() {
        viewModel.removeGuest("alice@test.com")
        #expect(viewModel.guests.isEmpty)
    }
}
