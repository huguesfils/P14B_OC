//
//  EventListView.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 26/04/2026.
//

import SwiftUI

struct EventListView: View {
    @State private var viewModel: EventListViewModel
    @State private var showCreateEvent = false

    private let container: DIContainer
    private let onSignOut: () -> Void

    init(container: DIContainer, onSignOut: @escaping () -> Void) {
        self.container = container
        self.onSignOut = onSignOut
        self._viewModel = State(
            initialValue: EventListViewModel(eventService: container.eventService)
        )
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Events")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Sign Out", role: .destructive, action: onSignOut)
                    }
                    ToolbarItem(placement: .primaryAction) {
                        categoryFilterMenu
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button("New Event", systemImage: "plus") {
                            showCreateEvent = true
                        }
                    }
                }
                .navigationDestination(for: Event.self) { event in
                    EventDetailView(event: event, container: container)
                }
                .sheet(isPresented: $showCreateEvent, onDismiss: reload) {
                    EventCreationView(container: container)
                }
                .task {
                    await viewModel.loadEvents()
                }
                .refreshable {
                    await viewModel.loadEvents()
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.events.isEmpty {
            ProgressView()
                .controlSize(.large)
        } else if let errorMessage = viewModel.errorMessage, viewModel.events.isEmpty {
            ContentUnavailableView {
                Label("Unable to load events", systemImage: "exclamationmark.triangle")
            } description: {
                Text(errorMessage)
            } actions: {
                Button("Retry") {
                    Task { await viewModel.loadEvents() }
                }
                .buttonStyle(.borderedProminent)
            }
        } else if viewModel.events.isEmpty {
            ContentUnavailableView {
                Label("No events yet", systemImage: "calendar")
            } description: {
                Text("Tap + to create your first event")
            }
        } else if viewModel.filteredEvents.isEmpty {
            ContentUnavailableView {
                Label("No matching events", systemImage: "line.3.horizontal.decrease.circle")
            } description: {
                Text("Try clearing the category filter")
            } actions: {
                Button("Clear filter") { viewModel.clearFilter() }
                    .buttonStyle(.borderedProminent)
            }
        } else {
            List(viewModel.filteredEvents) { event in
                NavigationLink(value: event) {
                    EventRow(event: event)
                }
            }
            .listStyle(.plain)
        }
    }

    private var categoryFilterMenu: some View {
        Menu {
            Button("All categories") { viewModel.clearFilter() }
            Divider()
            ForEach(EventCategory.allCases, id: \.self) { category in
                Button(category.displayName) { viewModel.selectedCategory = category }
            }
        } label: {
            Image(systemName: viewModel.hasActiveFilter
                  ? "line.3.horizontal.decrease.circle.fill"
                  : "line.3.horizontal.decrease.circle")
        }
        .accessibilityLabel("Filter by category")
    }

    private func reload() {
        Task { await viewModel.loadEvents() }
    }
}

private struct EventRow: View {
    let event: Event

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(event.title)
                    .font(.headline)
                Spacer()
                Text(event.category.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.secondary.opacity(0.15), in: .capsule)
            }
            Text(event.date, format: .dateTime.day().month().year().hour().minute())
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(event.location)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    EventListView(container: DIContainer(), onSignOut: {})
}
