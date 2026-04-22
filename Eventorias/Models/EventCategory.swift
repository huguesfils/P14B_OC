//
//  EventCategory.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 22/04/2026.
//

import Foundation

enum EventCategory: String, Codable, CaseIterable, Sendable {
    case conference
    case workshop
    case social
    case sport
    case culture
    case music
    case other

    var displayName: String {
        switch self {
        case .conference: "Conference"
        case .workshop: "Workshop"
        case .social: "Social"
        case .sport: "Sport"
        case .culture: "Culture"
        case .music: "Music"
        case .other: "Other"
        }
    }
}
