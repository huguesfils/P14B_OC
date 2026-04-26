//
//  ProfileViewModelTests.swift
//  EventoriasTests
//
//  Created by Hugues Fils Caparos on 26/04/2026.
//

import Testing
import Foundation
@testable import Eventorias

@MainActor
@Suite("ProfileViewModel")
struct ProfileViewModelTests {

    // MARK: - Properties

    let mockAuthService: MockAuthService
    let mockNotificationService: MockNotificationService
    let viewModel: ProfileViewModel

    // MARK: - Init

    init() {
        let authService = MockAuthService()
        let notificationService = MockNotificationService()
        mockAuthService = authService
        mockNotificationService = notificationService
        viewModel = ProfileViewModel(
            authService: authService,
            notificationService: notificationService
        )
    }

    // MARK: - Initial state

    @Test("Initial state has no error and no loading")
    func initialState() {
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
    }

    @Test("userId reflects auth service")
    func userIdReflectsAuth() {
        #expect(viewModel.userId == "test-user-id")

        mockAuthService.currentUserId = nil
        #expect(viewModel.userId == nil)
    }

    // MARK: - signOut

    @Test("signOut succeeds and clears userId")
    func signOutSuccess() {
        let result = viewModel.signOut()

        #expect(result)
        #expect(mockAuthService.currentUserId == nil)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("signOut returns false and sets errorMessage when service throws")
    func signOutError() {
        mockAuthService.errorToThrow = EventoriasError.unknown("Sign out failed")

        let result = viewModel.signOut()

        #expect(!result)
        #expect(viewModel.errorMessage == "Sign out failed")
    }

    @Test("signOut clears previous error on success")
    func signOutClearsPreviousError() {
        mockAuthService.errorToThrow = EventoriasError.unknown("first error")
        _ = viewModel.signOut()
        #expect(viewModel.errorMessage != nil)

        mockAuthService.errorToThrow = nil
        let result = viewModel.signOut()

        #expect(result)
        #expect(viewModel.errorMessage == nil)
    }

    // MARK: - deleteAccount

    @Test("deleteAccount succeeds and clears userId")
    func deleteAccountSuccess() async {
        let result = await viewModel.deleteAccount()

        #expect(result)
        #expect(mockAuthService.currentUserId == nil)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
    }

    @Test("deleteAccount returns false and sets errorMessage when service throws")
    func deleteAccountError() async {
        mockAuthService.errorToThrow = EventoriasError.accountDeletionFailed("Re-auth required")

        let result = await viewModel.deleteAccount()

        #expect(!result)
        #expect(viewModel.errorMessage == "Re-auth required")
        #expect(viewModel.isLoading == false)
        #expect(mockAuthService.currentUserId == "test-user-id") // unchanged
    }

    @Test("deleteAccount clears previous error on success")
    func deleteAccountClearsPreviousError() async {
        mockAuthService.errorToThrow = EventoriasError.accountDeletionFailed("first")
        _ = await viewModel.deleteAccount()
        #expect(viewModel.errorMessage != nil)

        mockAuthService.errorToThrow = nil
        let result = await viewModel.deleteAccount()

        #expect(result)
        #expect(viewModel.errorMessage == nil)
    }

    // MARK: - Notifications

    @Test("refreshNotificationStatus mirrors the notification service")
    func refreshNotificationStatusMirrors() async {
        mockNotificationService.authorizationStatus = .authorized
        await viewModel.refreshNotificationStatus()
        #expect(viewModel.notificationStatus == .authorized)

        mockNotificationService.authorizationStatus = .denied
        await viewModel.refreshNotificationStatus()
        #expect(viewModel.notificationStatus == .denied)
    }

    @Test("canRequestNotifications is true only when status is notDetermined")
    func canRequestNotificationsTransitions() async {
        mockNotificationService.authorizationStatus = .notDetermined
        await viewModel.refreshNotificationStatus()
        #expect(viewModel.canRequestNotifications)

        mockNotificationService.authorizationStatus = .authorized
        await viewModel.refreshNotificationStatus()
        #expect(!viewModel.canRequestNotifications)

        mockNotificationService.authorizationStatus = .denied
        await viewModel.refreshNotificationStatus()
        #expect(!viewModel.canRequestNotifications)
    }

    @Test("requestNotificationAuthorization granted updates status to authorized")
    func requestNotificationAuthorizationGranted() async {
        mockNotificationService.requestAuthorizationResult = true

        await viewModel.requestNotificationAuthorization()

        #expect(viewModel.notificationStatus == .authorized)
        #expect(viewModel.errorMessage == nil)
        #expect(mockNotificationService.requestAuthorizationCalls == 1)
    }

    @Test("requestNotificationAuthorization denied updates status to denied")
    func requestNotificationAuthorizationDenied() async {
        mockNotificationService.requestAuthorizationResult = false

        await viewModel.requestNotificationAuthorization()

        #expect(viewModel.notificationStatus == .denied)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("requestNotificationAuthorization sets errorMessage when service throws")
    func requestNotificationAuthorizationError() async {
        mockNotificationService.errorToThrow = EventoriasError.unknown("blocked")
        mockNotificationService.authorizationStatus = .notDetermined

        await viewModel.requestNotificationAuthorization()

        #expect(viewModel.errorMessage == "blocked")
    }

    @Test("notificationStatusDescription covers all cases")
    func notificationStatusDescriptionCases() async {
        mockNotificationService.authorizationStatus = .notDetermined
        await viewModel.refreshNotificationStatus()
        #expect(viewModel.notificationStatusDescription == "Not requested yet")

        mockNotificationService.authorizationStatus = .authorized
        await viewModel.refreshNotificationStatus()
        #expect(viewModel.notificationStatusDescription == "Enabled")

        mockNotificationService.authorizationStatus = .provisional
        await viewModel.refreshNotificationStatus()
        #expect(viewModel.notificationStatusDescription == "Enabled (provisional)")

        mockNotificationService.authorizationStatus = .ephemeral
        await viewModel.refreshNotificationStatus()
        #expect(viewModel.notificationStatusDescription == "Enabled (ephemeral)")

        mockNotificationService.authorizationStatus = .denied
        await viewModel.refreshNotificationStatus()
        #expect(viewModel.notificationStatusDescription == "Disabled in Settings")
    }
}
