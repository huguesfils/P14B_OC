//
//  EventoriasError.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 09/03/2026.
//

import Foundation

enum EventoriasError: LocalizedError {
    case authenticationFailed(String)
    case registrationFailed(String)
    case passwordResetFailed(String)
    case accountDeletionFailed(String)
    case eventCreationFailed(String)
    case eventFetchFailed(String)
    case eventUpdateFailed(String)
    case eventDeletionFailed(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .authenticationFailed(let message): message
        case .registrationFailed(let message): message
        case .passwordResetFailed(let message): message
        case .accountDeletionFailed(let message): message
        case .eventCreationFailed(let message): message
        case .eventFetchFailed(let message): message
        case .eventUpdateFailed(let message): message
        case .eventDeletionFailed(let message): message
        case .unknown(let message): message
        }
    }
}
