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
                .tint(Color.evenRed)

                Divider()

                dayEventsList
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.evenBlack)
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
                        .buttonStyle(.eventoriasPrimary)
                        .padding(.horizontal)
                    }
                }
            }
        }
        .tint(Color.evenRed)
    }

    private func accessibilityDescription(for event: Event) -> String {
        let time = event.date.formatted(date: .omitted, time: .shortened)
        return "\(event.title), \(time), \(event.location)"
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
                            .foregroundStyle(.white)
                        Text(event.date, format: .dateTime.hour().minute())
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                        Text(event.location)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(accessibilityDescription(for: event))
                }
                .listRowBackground(Color.evenGray)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }
}

#Preview {
    EventCalendarView(container: DIContainer())
}
