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
    let viewModel: ProfileViewModel

    // MARK: - Init

    init() {
        let service = MockAuthService()
        mockAuthService = service
        viewModel = ProfileViewModel(authService: service)
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
}
