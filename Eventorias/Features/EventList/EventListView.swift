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

    init(container: DIContainer) {
        self.container = container
        self._viewModel = State(
            initialValue: EventListViewModel(eventService: container.eventService)
        )
    }

    var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.evenBlack)
                .navigationTitle("Events")
                .searchable(text: $viewModel.searchText, prompt: "Search by title or location")
                .toolbar {
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
        .tint(Color.evenRed)
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
                .buttonStyle(.eventoriasPrimary)
                .padding(.horizontal)
            }
        } else if viewModel.events.isEmpty {
            ContentUnavailableView {
                Label("No events yet", systemImage: "calendar")
            } description: {
                Text("Tap + to create your first event")
            }
        } else if viewModel.filteredEvents.isEmpty {
            ContentUnavailableView {
                Label("No matching events", systemImage: "magnifyingglass")
            } description: {
                Text(noMatchDescription)
            } actions: {
                Button("Clear filters") {
                    viewModel.clearFilter()
                    viewModel.clearSearch()
                }
                .buttonStyle(.eventoriasPrimary)
                .padding(.horizontal)
            }
        } else {
            List(viewModel.filteredEvents) { event in
                NavigationLink(value: event) {
                    EventRow(event: event)
                }
                .listRowBackground(Color.evenGray)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .animation(.default, value: viewModel.filteredEvents)
        }
    }

    private var noMatchDescription: String {
        switch (viewModel.hasActiveSearch, viewModel.hasActiveFilter) {
        case (true, true): "No event matches your search and selected category."
        case (true, false): "No event matches your search."
        case (false, true): "No event in the selected category."
        case (false, false): "No matching events."
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
                    .foregroundStyle(.white)
                Spacer()
                Text(event.category.displayName)
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.white.opacity(0.15), in: .capsule)
            }
            Text(event.date, format: .dateTime.day().month().year().hour().minute())
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
            Text(event.location)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    private var accessibilityDescription: String {
        let date = event.date.formatted(date: .long, time: .shortened)
        return "\(event.title), \(event.category.displayName), \(date), \(event.location)"
    }
}

#Preview {
    EventListView(container: DIContainer())
}
