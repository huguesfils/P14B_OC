//
//  AuthenticationViewModelTests.swift
//  EventoriasTests
//
//  Created by Hugues Fils Caparos on 07/05/2026.
//

import Testing
import Foundation
@testable import Eventorias

@MainActor
@Suite("AuthenticationViewModel")
struct AuthenticationViewModelTests {

    // MARK: - Properties

    let mockAuthService: MockAuthService
    let viewModel: AuthenticationViewModel

    // MARK: - Init

    init() {
        let authService = MockAuthService()
        mockAuthService = authService
        viewModel = AuthenticationViewModel(authService: authService)
    }

    // MARK: - Initial state

    @Test("Initial state is empty with no error and not loading")
    func initialState() {
        #expect(viewModel.email == "")
        #expect(viewModel.password == "")
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
    }

    // MARK: - Validation

    @Test("signIn returns false and sets error when email is empty")
    func signInEmptyEmail() async {
        viewModel.email = ""
        viewModel.password = "password123"

        let result = await viewModel.signIn()

        #expect(!result)
        #expect(viewModel.errorMessage == "Please enter your email")
        #expect(viewModel.isLoading == false)
    }

    @Test("signIn returns false and sets error when email is whitespace")
    func signInWhitespaceEmail() async {
        viewModel.email = "   "
        viewModel.password = "password123"

        let result = await viewModel.signIn()

        #expect(!result)
        #expect(viewModel.errorMessage == "Please enter your email")
    }

    @Test("signIn returns false and sets error when password is empty")
    func signInEmptyPassword() async {
        viewModel.email = "user@test.com"
        viewModel.password = ""

        let result = await viewModel.signIn()

        #expect(!result)
        #expect(viewModel.errorMessage == "Please enter your password")
        #expect(viewModel.isLoading == false)
    }

    // MARK: - signIn

    @Test("signIn returns true and clears error on success")
    func signInSuccess() async {
        viewModel.email = "user@test.com"
        viewModel.password = "password123"

        let result = await viewModel.signIn()

        #expect(result)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
    }

    @Test("signIn returns false and sets errorMessage when service throws")
    func signInError() async {
        viewModel.email = "user@test.com"
        viewModel.password = "password123"
        mockAuthService.errorToThrow = EventoriasError.unknown("Invalid credentials")

        let result = await viewModel.signIn()

        #expect(!result)
        #expect(viewModel.errorMessage == "Invalid credentials")
        #expect(viewModel.isLoading == false)
    }

    @Test("signIn clears previous error on success")
    func signInClearsPreviousError() async {
        viewModel.email = "user@test.com"
        viewModel.password = "password123"
        mockAuthService.errorToThrow = EventoriasError.unknown("first error")
        _ = await viewModel.signIn()
        #expect(viewModel.errorMessage != nil)

        mockAuthService.errorToThrow = nil
        let result = await viewModel.signIn()

        #expect(result)
        #expect(viewModel.errorMessage == nil)
    }
}
