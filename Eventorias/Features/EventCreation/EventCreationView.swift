//
//  EventCreationView.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 22/04/2026.
//

import SwiftUI

struct EventCreationView: View {
    @State private var viewModel: EventCreationViewModel
    @Environment(\.dismiss) private var dismiss

    init(container: DIContainer) {
        self._viewModel = State(
            initialValue: EventCreationViewModel(
                eventService: container.eventService,
                authService: container.authService,
                notificationService: container.notificationService
            )
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Event Details") {
                    TextField("Title", text: $viewModel.title)

                    TextField("Description", text: $viewModel.description, axis: .vertical)
                        .lineLimit(3...6)

                    DatePicker("Date & Time", selection: $viewModel.date, in: Date()...,
                               displayedComponents: [.date, .hourAndMinute])

                    TextField("Location", text: $viewModel.location)

                    Picker("Category", selection: $viewModel.category) {
                        ForEach(EventCategory.allCases, id: \.self) { category in
                            Text(category.displayName).tag(category)
                        }
                    }
                }

                Section("Guests") {
                    HStack {
                        TextField("Email", text: $viewModel.guestEmail)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()

                        Button("Add") {
                            viewModel.addGuest()
                        }
                        .disabled(viewModel.guestEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }

                    ForEach(viewModel.guests, id: \.self) { guest in
                        HStack {
                            Text(guest)
                            Spacer()
                            Button("Remove", role: .destructive) {
                                viewModel.removeGuest(guest)
                            }
                            .font(.caption)
                        }
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("New Event")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Task {
                            let success = await viewModel.createEvent()
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
    }
}

#Preview {
    EventCreationView(container: DIContainer())
}
