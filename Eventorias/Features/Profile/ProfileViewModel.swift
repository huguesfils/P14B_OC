//
//  ProfileViewModel.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 26/04/2026.
//

import Foundation

@Observable
final class ProfileViewModel {
    var errorMessage: String?
    var isLoading = false
    var notificationStatus: NotificationAuthorizationStatus = .notDetermined

    private let authService: AuthServiceProtocol
    private let notificationService: NotificationServiceProtocol

    init(authService: AuthServiceProtocol, notificationService: NotificationServiceProtocol) {
        self.authService = authService
        self.notificationService = notificationService
    }

    var userId: String? {
        authService.currentUserId
    }

    var canRequestNotifications: Bool {
        notificationStatus == .notDetermined
    }

    var notificationStatusDescription: String {
        switch notificationStatus {
        case .authorized: "Enabled"
        case .provisional: "Enabled (provisional)"
        case .ephemeral: "Enabled (ephemeral)"
        case .denied: "Disabled in Settings"
        case .notDetermined: "Not requested yet"
        }
    }

    func refreshNotificationStatus() async {
        notificationStatus = await notificationService.currentAuthorizationStatus()
    }

    func requestNotificationAuthorization() async {
        errorMessage = nil
        do {
            _ = try await notificationService.requestAuthorization()
        } catch {
            errorMessage = error.localizedDescription
        }
        await refreshNotificationStatus()
    }

    func signOut() -> Bool {
        errorMessage = nil
        do {
            try authService.signOut()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func deleteAccount() async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            try await authService.deleteAccount()
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
}
