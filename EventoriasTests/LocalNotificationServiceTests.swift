//
//  LocalNotificationServiceTests.swift
//  EventoriasTests
//
//  Created by Hugues Fils Caparos on 11/05/2026.
//

import Testing
import Foundation
import UserNotifications
@testable import Eventorias

@Suite("LocalNotificationService")
struct LocalNotificationServiceTests {

    // MARK: - Helpers

    private func makeSUT(reminderLeadTime: TimeInterval = 3600) -> (LocalNotificationService, MockUserNotificationCenter) {
        let center = MockUserNotificationCenter()
        let service = LocalNotificationService(center: center, reminderLeadTime: reminderLeadTime)
        return (service, center)
    }

    private func makeEvent(id: String = "evt-1", date: Date) -> Event {
        Event(
            id: id,
            title: "WWDC",
            description: "Keynote",
            date: date,
            location: "Cupertino",
            category: .conference,
            creatorId: "creator-1",
            guests: []
        )
    }

    // MARK: - currentAuthorizationStatus

    @Test("Maps notDetermined status")
    func mapsNotDetermined() async {
        let (sut, center) = makeSUT()
        center.stubAuthorizationStatus = .notDetermined
        let status = await sut.currentAuthorizationStatus()
        #expect(status == .notDetermined)
    }

    @Test("Maps authorized status")
    func mapsAuthorized() async {
        let (sut, center) = makeSUT()
        center.stubAuthorizationStatus = .authorized
        let status = await sut.currentAuthorizationStatus()
        #expect(status == .authorized)
    }

    @Test("Maps denied status")
    func mapsDenied() async {
        let (sut, center) = makeSUT()
        center.stubAuthorizationStatus = .denied
        let status = await sut.currentAuthorizationStatus()
        #expect(status == .denied)
    }

    @Test("Maps provisional status")
    func mapsProvisional() async {
        let (sut, center) = makeSUT()
        center.stubAuthorizationStatus = .provisional
        let status = await sut.currentAuthorizationStatus()
        #expect(status == .provisional)
    }

    @Test("Maps ephemeral status")
    func mapsEphemeral() async {
        let (sut, center) = makeSUT()
        center.stubAuthorizationStatus = .ephemeral
        let status = await sut.currentAuthorizationStatus()
        #expect(status == .ephemeral)
    }

    // MARK: - requestAuthorization

    @Test("requestAuthorization returns true when granted and forwards options")
    func requestAuthorizationGranted() async throws {
        let (sut, center) = makeSUT()
        center.requestAuthorizationResult = true

        let granted = try await sut.requestAuthorization()

        #expect(granted == true)
        #expect(center.requestAuthorizationOptions == [.alert, .sound, .badge])
    }

    @Test("requestAuthorization returns false when denied")
    func requestAuthorizationDenied() async throws {
        let (sut, center) = makeSUT()
        center.requestAuthorizationResult = false

        let granted = try await sut.requestAuthorization()

        #expect(granted == false)
    }

    @Test("requestAuthorization wraps underlying error as EventoriasError.unknown")
    func requestAuthorizationThrows() async {
        let (sut, center) = makeSUT()
        center.errorToThrow = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "boom"])

        await #expect(throws: EventoriasError.self) {
            _ = try await sut.requestAuthorization()
        }
    }

    // MARK: - scheduleReminder

    @Test("scheduleReminder is no-op when trigger date is in the past")
    func scheduleReminderInPast() async throws {
        let (sut, center) = makeSUT(reminderLeadTime: 3600)
        // event in 30 min → trigger date (event - 1h) is in the past
        let event = makeEvent(date: Date().addingTimeInterval(30 * 60))

        try await sut.scheduleReminder(for: event)

        #expect(center.addedRequests.isEmpty)
    }

    @Test("scheduleReminder adds a request with event id, title and location in the future")
    func scheduleReminderInFuture() async throws {
        let (sut, center) = makeSUT(reminderLeadTime: 3600)
        // event in 3h → trigger date (event - 1h) is 2h from now → future
        let event = makeEvent(id: "evt-42", date: Date().addingTimeInterval(3 * 3600))

        try await sut.scheduleReminder(for: event)

        let request = try #require(center.addedRequests.first)
        #expect(request.identifier == "evt-42")
        #expect(request.content.title == "WWDC")
        #expect(request.content.body.contains("Cupertino"))
        #expect(request.trigger is UNCalendarNotificationTrigger)

        let trigger = try #require(request.trigger as? UNCalendarNotificationTrigger)
        #expect(trigger.repeats == false)
    }

    @Test("scheduleReminder wraps underlying error as EventoriasError")
    func scheduleReminderThrows() async {
        let (sut, center) = makeSUT(reminderLeadTime: 3600)
        center.errorToThrow = NSError(domain: "test", code: 2, userInfo: [NSLocalizedDescriptionKey: "fail"])
        let event = makeEvent(date: Date().addingTimeInterval(3 * 3600))

        await #expect(throws: EventoriasError.self) {
            try await sut.scheduleReminder(for: event)
        }
    }

    // MARK: - cancelReminder

    @Test("cancelReminder removes the pending request for the given event id")
    func cancelReminderRemovesIdentifier() async {
        let (sut, center) = makeSUT()

        await sut.cancelReminder(forEventId: "evt-99")

        #expect(center.removedIdentifiers == ["evt-99"])
    }
}
