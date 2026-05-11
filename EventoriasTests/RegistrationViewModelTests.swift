//
//  RegistrationViewModelTests.swift
//  EventoriasTests
//
//  Created by Hugues Fils Caparos on 07/05/2026.
//

import Testing
import Foundation
@testable import Eventorias

@MainActor
@Suite("RegistrationViewModel")
struct RegistrationViewModelTests {

    // MARK: - Properties

    let mockAuthService: MockAuthService
    let viewModel: RegistrationViewModel

    // MARK: - Init

    init() {
        let authService = MockAuthService()
        mockAuthService = authService
        viewModel = RegistrationViewModel(authService: authService)
    }

    // MARK: - Initial state

    @Test("Initial state is empty with no error and not loading")
    func initialState() {
        #expect(viewModel.email == "")
        #expect(viewModel.password == "")
        #expect(viewModel.confirmPassword == "")
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
    }

    // MARK: - Validation

    @Test("register returns false and sets error when email is empty")
    func registerEmptyEmail() async {
        viewModel.email = ""
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"

        let result = await viewModel.register()

        #expect(!result)
        #expect(viewModel.errorMessage == "Please enter your email")
        #expect(viewModel.isLoading == false)
    }

    @Test("register returns false and sets error when email is whitespace")
    func registerWhitespaceEmail() async {
        viewModel.email = "   "
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"

        let result = await viewModel.register()

        #expect(!result)
        #expect(viewModel.errorMessage == "Please enter your email")
    }

    @Test("register returns false and sets error when password is empty")
    func registerEmptyPassword() async {
        viewModel.email = "user@test.com"
        viewModel.password = ""
        viewModel.confirmPassword = ""

        let result = await viewModel.register()

        #expect(!result)
        #expect(viewModel.errorMessage == "Please enter a password")
    }

    @Test("register returns false and sets error when password is too short")
    func registerPasswordTooShort() async {
        viewModel.email = "user@test.com"
        viewModel.password = "12345"
        viewModel.confirmPassword = "12345"

        let result = await viewModel.register()

        #expect(!result)
        #expect(viewModel.errorMessage == "Password must be at least 6 characters")
    }

    @Test("register returns false and sets error when passwords do not match")
    func registerPasswordsDontMatch() async {
        viewModel.email = "user@test.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "different123"

        let result = await viewModel.register()

        #expect(!result)
        #expect(viewModel.errorMessage == "Passwords do not match")
    }

    // MARK: - register

    @Test("register returns true and clears error on success")
    func registerSuccess() async {
        viewModel.email = "user@test.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"

        let result = await viewModel.register()

        #expect(result)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
    }

    @Test("register returns false and sets errorMessage when service throws")
    func registerError() async {
        viewModel.email = "user@test.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        mockAuthService.errorToThrow = EventoriasError.unknown("Email already in use")

        let result = await viewModel.register()

        #expect(!result)
        #expect(viewModel.errorMessage == "Email already in use")
        #expect(viewModel.isLoading == false)
    }

    @Test("register clears previous error on success")
    func registerClearsPreviousError() async {
        viewModel.email = "user@test.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        mockAuthService.errorToThrow = EventoriasError.unknown("first error")
        _ = await viewModel.register()
        #expect(viewModel.errorMessage != nil)

        mockAuthService.errorToThrow = nil
        let result = await viewModel.register()

        #expect(result)
        #expect(viewModel.errorMessage == nil)
    }
}
