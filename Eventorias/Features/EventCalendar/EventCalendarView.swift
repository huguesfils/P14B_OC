//
//  EventCalendarView.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 26/04/2026.
//

import SwiftUI

struct EventCalendarView: View {
    @State private var viewModel: EventCalendarViewModel

    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
        self._viewModel = State(
            initialValue: EventCalendarViewModel(eventService: container.eventService)
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DatePicker(
                    "Select date",
                    selection: $viewModel.selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding(.horizontal)

                Divider()

                dayEventsList
            }
            .navigationTitle("Calendar")
            .navigationDestination(for: Event.self) { event in
                EventDetailView(event: event, container: container)
            }
            .task {
                await viewModel.loadEvents()
            }
            .refreshable {
                await viewModel.loadEvents()
            }
            .overlay {
                if let errorMessage = viewModel.errorMessage, viewModel.events.isEmpty {
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
                }
            }
        }
    }

    @ViewBuilder
    private var dayEventsList: some View {
        let dayEvents = viewModel.eventsForSelectedDate
        if dayEvents.isEmpty {
            ContentUnavailableView(
                "No events on this day",
                systemImage: "calendar.badge.exclamationmark"
            )
            .frame(maxHeight: .infinity)
        } else {
            List(dayEvents) { event in
                NavigationLink(value: event) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.title)
                            .font(.headline)
                        Text(event.date, format: .dateTime.hour().minute())
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(event.location)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}

#Preview {
    EventCalendarView(container: DIContainer())
}
