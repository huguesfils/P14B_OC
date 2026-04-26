//
//  EventShareTextBuilder.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 26/04/2026.
//

import Foundation

enum EventShareTextBuilder {
    static func text(
        for event: Event,
        locale: Locale = .current,
        timeZone: TimeZone = .current
    ) -> String {
        let style = Date.FormatStyle(
            date: .long,
            time: .shortened,
            locale: locale,
            timeZone: timeZone
        )
        let formattedDate = event.date.formatted(style)

        var lines = [
            event.title,
            "\(formattedDate) — \(event.location)",
            "",
            event.description
        ]

        if !event.guests.isEmpty {
            lines.append("")
            lines.append("Guests: \(event.guests.joined(separator: ", "))")
        }

        return lines.joined(separator: "\n")
    }
}
