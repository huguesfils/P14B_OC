//
//  EventShareTextBuilderTests.swift
//  EventoriasTests
//
//  Created by Hugues Fils Caparos on 26/04/2026.
//

import Testing
import Foundation
@testable import Eventorias

@Suite("EventShareTextBuilder")
struct EventShareTextBuilderTests {

    // MARK: - Helpers

    private let fixedLocale = Locale(identifier: "en_US_POSIX")
    private let fixedTimeZone = TimeZone(identifier: "UTC") ?? .gmt

    private func makeEvent(
        title: String = "Swift Meetup",
        description: String = "A meetup about Swift",
        location: String = "Paris",
        guests: [String] = []
    ) -> Event {
        var components = DateComponents()
        components.year = 2026
        components.month = 6
        components.day = 1
        components.hour = 18
        components.minute = 30
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = fixedTimeZone
        let date = calendar.date(from: components) ?? Date(timeIntervalSince1970: 0)

        return Event(
            id: "event-1",
            title: title,
            description: description,
            date: date,
            location: location,
            category: .conference,
            creatorId: "creator",
            guests: guests
        )
    }

    private func text(for event: Event) -> String {
        EventShareTextBuilder.text(for: event, locale: fixedLocale, timeZone: fixedTimeZone)
    }

    // MARK: - Tests

    @Test("Includes title on the first line")
    func includesTitle() {
        let event = makeEvent(title: "Swift Meetup")
        let result = text(for: event)
        let firstLine = result.split(separator: "\n").first.map(String.init)
        #expect(firstLine == "Swift Meetup")
    }

    @Test("Includes formatted date and location on the second line")
    func includesDateAndLocation() {
        let event = makeEvent(location: "Lyon")
        let result = text(for: event)
        #expect(result.contains("Lyon"))
        #expect(result.contains("June 1, 2026"))
        #expect(result.contains("6:30"))
    }

    @Test("Includes description")
    func includesDescription() {
        let event = makeEvent(description: "Annual conference")
        let result = text(for: event)
        #expect(result.contains("Annual conference"))
    }

    @Test("Omits guests section when there are no guests")
    func omitsGuestsWhenEmpty() {
        let event = makeEvent(guests: [])
        let result = text(for: event)
        #expect(!result.contains("Guests:"))
    }

    @Test("Includes guests joined by comma when present")
    func includesGuestsWhenPresent() {
        let event = makeEvent(guests: ["alice@test.com", "bob@test.com"])
        let result = text(for: event)
        #expect(result.contains("Guests: alice@test.com, bob@test.com"))
    }
}
