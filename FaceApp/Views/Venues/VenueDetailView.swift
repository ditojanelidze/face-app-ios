import SwiftUI

struct VenueDetailView: View {
    let venue: Venue
    @StateObject private var venueService = VenueService()
    @StateObject private var approvalService = ApprovalService()
    @EnvironmentObject var authManager: AuthManager

    @State private var events: [Event] = []
    @State private var isLoading = true
    @State private var showingApprovalSheet = false
    @State private var selectedEvent: Event?
    @State private var showingSuccess = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                venueHeader

                // Quick Actions
                actionButtons

                // Events Section
                eventsSection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(venue.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadEvents()
        }
        .sheet(isPresented: $showingApprovalSheet) {
            ApprovalRequestSheet(
                venue: venue,
                event: selectedEvent,
                approvalService: approvalService,
                onSuccess: {
                    showingSuccess = true
                    showingApprovalSheet = false
                }
            )
        }
        .alert("Request Submitted", isPresented: $showingSuccess) {
            Button("OK") { }
        } message: {
            Text("Your approval request has been submitted. You'll be notified when it's reviewed.")
        }
    }

    // MARK: - Venue Header

    private var venueHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Gradient Header
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [.purple.opacity(0.8), .blue.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 160)

                VStack {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.white)

                    Text(venue.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
            }

            // Details
            if let address = venue.address {
                HStack(spacing: 8) {
                    Image(systemName: "location.fill")
                        .foregroundStyle(.blue)
                    Text(address)
                        .font(.subheadline)
                }
            }

            if let description = venue.description {
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                selectedEvent = nil
                showingApprovalSheet = true
            } label: {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                    Text("Request Global Access")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!profileComplete)
            .opacity(profileComplete ? 1 : 0.6)

            if !profileComplete {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text("Complete your profile to request access")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var profileComplete: Bool {
        authManager.currentUser?.profileComplete ?? false
    }

    // MARK: - Events Section

    private var eventsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Events")
                .font(.headline)

            if isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding()
            } else if events.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("No upcoming events")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 32)
            } else {
                ForEach(events) { event in
                    EventCard(event: event, profileComplete: profileComplete) {
                        selectedEvent = event
                        showingApprovalSheet = true
                    }
                }
            }
        }
    }

    private func loadEvents() async {
        isLoading = true
        do {
            events = try await venueService.fetchEvents(venueId: venue.id)
        } catch {
            // Handle error silently
        }
        isLoading = false
    }
}

// MARK: - Event Card

struct EventCard: View {
    let event: Event
    let profileComplete: Bool
    let onRequestAccess: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.name)
                        .font(.headline)

                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text(event.formattedDate)
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }

                Spacer()

                // Event badge
                if event.allowGlobalApproval {
                    Text("Open")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .clipShape(Capsule())
                } else {
                    Text("Exclusive")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(Capsule())
                }
            }

            if let description = event.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Button {
                onRequestAccess()
            } label: {
                Text("Request Access")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.blue)
            }
            .disabled(!profileComplete)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Approval Request Sheet

struct ApprovalRequestSheet: View {
    let venue: Venue
    let event: Event?
    @ObservedObject var approvalService: ApprovalService
    let onSuccess: () -> Void
    @Environment(\.dismiss) var dismiss

    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.blue)

                    Text(event != nil ? "Event Access Request" : "Global Access Request")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.top, 32)

                // Details
                VStack(alignment: .leading, spacing: 16) {
                    detailRow(icon: "building.2", title: "Venue", value: venue.name)

                    if let event = event {
                        detailRow(icon: "calendar", title: "Event", value: event.name)
                        detailRow(icon: "clock", title: "Date", value: event.formattedDate)
                    } else {
                        detailRow(icon: "checkmark.seal", title: "Type", value: "Global Access")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(event != nil
                     ? "This request grants you access to this specific event only."
                     : "Global access allows entry to events that accept global approvals.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                Spacer()

                Button {
                    submitRequest()
                } label: {
                    HStack {
                        if isSubmitting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Submit Request")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isSubmitting)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }

    private func submitRequest() {
        isSubmitting = true
        errorMessage = nil

        Task {
            do {
                let type: ApprovalType = event != nil ? .eventSpecific : .global
                _ = try await approvalService.requestApproval(
                    venueId: venue.id,
                    eventId: event?.id,
                    type: type
                )
                onSuccess()
            } catch {
                errorMessage = error.localizedDescription
            }
            isSubmitting = false
        }
    }
}

#Preview {
    NavigationStack {
        VenueDetailView(venue: Venue(
            id: 1,
            name: "Sky Bar",
            description: "Rooftop bar with stunning city views",
            address: "123 Main Street",
            createdAt: nil,
            updatedAt: nil,
            upcomingEvents: nil
        ))
    }
    .environmentObject(AuthManager())
}
