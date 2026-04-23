//
//  Event.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 09/03/2026.
//

import Foundation

struct Event: Identifiable, Codable, Sendable {
    var id: String
    var title: String
    var description: String
    var date: Date
    var location: String
    var category: String
    var creatorId: String
    var guests: [String]
}
