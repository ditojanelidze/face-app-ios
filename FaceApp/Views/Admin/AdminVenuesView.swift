import SwiftUI

struct AdminVenuesView: View {
    @StateObject private var adminService = AdminService()

    var body: some View {
        NavigationStack {
            Group {
                if adminService.isLoading && adminService.venues.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if adminService.venues.isEmpty {
                    ContentUnavailableView(
                        "No Venues",
                        systemImage: "building.2.slash",
                        description: Text("You don't have any venues yet.")
                    )
                } else {
                    List(adminService.venues) { venue in
                        NavigationLink(destination: AdminVenueDetailView(venue: venue)) {
                            AdminVenueRow(venue: venue)
                        }
                    }
                    .listStyle(.plain)
                    .refreshable { await adminService.fetchVenues() }
                }
            }
            .navigationTitle("My Venues")
            .alert("Error", isPresented: .constant(adminService.error != nil)) {
                Button("OK") { adminService.error = nil }
            } message: {
                Text(adminService.error ?? "")
            }
        }
        .task { await adminService.fetchVenues() }
    }
}

// MARK: - Venue Row

struct AdminVenueRow: View {
    let venue: AdminVenue

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(venue.name)
                .font(.headline)

            if let address = venue.address, !address.isEmpty {
                Label(address, systemImage: "mappin")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let description = venue.description, !description.isEmpty {
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AdminVenuesView()
        .environmentObject(AuthManager())
}
