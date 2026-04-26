//
//  EventDetailView.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 26/04/2026.
//

import SwiftUI

struct EventDetailView: View {
    @State private var viewModel: EventDetailViewModel
    @State private var showDeleteConfirmation = false
    @Environment(\.dismiss) private var dismiss

    init(event: Event, container: DIContainer) {
        self._viewModel = State(
            initialValue: EventDetailViewModel(
                event: event,
                eventService: container.eventService,
                authService: container.authService
            )
        )
    }

    var body: some View {
        Form {
            if viewModel.isEditing {
                editingSections
            } else {
                readSections
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(viewModel.isEditing ? "Edit Event" : viewModel.event.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .confirmationDialog(
            "Delete this event?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                Task {
                    let success = await viewModel.deleteEvent()
                    if success { dismiss() }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }

    @ViewBuilder
    private var readSections: some View {
        Section("Details") {
            LabeledContent("Description", value: viewModel.event.description)
            LabeledContent("Date") {
                Text(viewModel.event.date, format: .dateTime.day().month().year().hour().minute())
            }
            LabeledContent("Location", value: viewModel.event.location)
            LabeledContent("Category", value: viewModel.event.category.displayName)
        }

        if !viewModel.event.guests.isEmpty {
            Section("Guests") {
                ForEach(viewModel.event.guests, id: \.self) { guest in
                    Text(guest)
                }
            }
        }
    }

    @ViewBuilder
    private var editingSections: some View {
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
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        if viewModel.isEditing {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    viewModel.cancelEditing()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task { await viewModel.saveChanges() }
                }
                .disabled(viewModel.isLoading)
            }
        } else if viewModel.canEdit {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("Edit", systemImage: "pencil") {
                        viewModel.startEditing()
                    }
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        EventDetailView(
            event: Event(
                id: "1",
                title: "Swift Meetup",
                description: "A meetup about Swift",
                date: Date().addingTimeInterval(86_400),
                location: "Paris",
                category: .conference,
                creatorId: "test-user-id",
                guests: ["alice@test.com", "bob@test.com"]
            ),
            container: DIContainer()
        )
    }
}
