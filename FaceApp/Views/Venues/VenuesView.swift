import SwiftUI

struct VenuesView: View {
    @StateObject private var venueService = VenueService()
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(venueService.venues) { venue in
                        NavigationLink(destination: VenueDetailView(venue: venue)) {
                            VenueCard(venue: venue)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Venues")
            .refreshable {
                await venueService.fetchVenues()
            }
            .overlay {
                if venueService.isLoading && venueService.venues.isEmpty {
                    ProgressView()
                }
            }
            .task {
                await venueService.fetchVenues()
            }
        }
    }
}

// MARK: - Venue Card

struct VenueCard: View {
    let venue: Venue

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Venue Header
            HStack {
                // Venue Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)

                    Image(systemName: "building.2.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(venue.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    if let address = venue.address {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.caption2)
                            Text(address)
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }

            // Description
            if let description = venue.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            // Upcoming Events Preview
            if let events = venue.upcomingEvents, !events.isEmpty {
                Divider()

                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(.blue)
                    Text("\(events.count) upcoming event\(events.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    VenuesView()
        .environmentObject(AuthManager())
}
