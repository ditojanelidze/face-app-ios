import SwiftUI

struct AdminVenueDetailView: View {
    let venue: AdminVenue

    @StateObject private var adminService = AdminService()
    @State private var detailedVenue: AdminVenue?
    @State private var showPendingOnly = true

    private var displayedVenue: AdminVenue { detailedVenue ?? venue }

    var body: some View {
        List {
            // Stats Section
            if let stats = displayedVenue.stats {
                Section("Overview") {
                    statsGrid(stats: stats)
                }
            }

            // Approvals Filter
            Section {
                Picker("Filter", selection: $showPendingOnly) {
                    Text("Pending").tag(true)
                    Text("All").tag(false)
                }
                .pickerStyle(.segmented)
            }

            // Approvals List
            Section(showPendingOnly ? "Pending Approvals" : "All Approvals") {
                if adminService.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else if adminService.approvals.isEmpty {
                    Text(showPendingOnly ? "No pending approvals" : "No approvals yet")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                } else {
                    ForEach(adminService.approvals) { approval in
                        NavigationLink(destination: AdminApprovalDetailView(
                            approval: approval,
                            venueId: venue.id,
                            onUpdate: { updated in
                                if let idx = adminService.approvals.firstIndex(where: { $0.id == updated.id }) {
                                    adminService.approvals[idx] = updated
                                }
                            }
                        )) {
                            AdminApprovalRow(approval: approval)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(venue.name)
        .navigationBarTitleDisplayMode(.large)
        .task { await loadAll() }
        .onChange(of: showPendingOnly) { _, _ in
            Task { await adminService.fetchApprovals(venueId: venue.id, pendingOnly: showPendingOnly) }
        }
        .refreshable { await loadAll() }
    }

    private func loadAll() async {
        async let detail: () = loadDetail()
        async let approvals: () = adminService.fetchApprovals(venueId: venue.id, pendingOnly: showPendingOnly)
        _ = await (detail, approvals)
    }

    private func loadDetail() async {
        detailedVenue = try? await adminService.fetchVenueDetail(id: venue.id)
    }

    @ViewBuilder
    private func statsGrid(stats: VenueStats) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(value: "\(stats.pendingApprovals)", label: "Pending", color: .orange, icon: "clock")
            StatCard(value: "\(stats.approvedUsers)", label: "Approved", color: .green, icon: "checkmark.circle")
            StatCard(value: "\(stats.upcomingEvents)", label: "Upcoming", color: .blue, icon: "calendar")
            StatCard(value: "\(stats.totalEvents)", label: "Total Events", color: .purple, icon: "list.bullet")
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Approval Row

struct AdminApprovalRow: View {
    let approval: AdminApproval

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(approval.user.fullName)
                    .font(.headline)
                Spacer()
                StatusBadge(status: approval.status)
            }

            HStack(spacing: 12) {
                Label(approval.user.phoneNumber, systemImage: "phone")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Label(approval.approvalTypeLabel, systemImage: approval.approvalType == "event_specific" ? "ticket" : "globe")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let event = approval.event {
                Label(event.name, systemImage: "music.note")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let value: String
    let label: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let status: String

    var color: Color {
        switch status {
        case "approved": return .green
        case "rejected": return .red
        default: return .orange
        }
    }

    var body: some View {
        Text(status.capitalized)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }
}

#Preview {
    NavigationStack {
        AdminVenueDetailView(venue: AdminVenue(
            id: 1, name: "Club Noir", description: "Premium nightclub",
            address: "123 Main St", stats: nil, createdAt: nil, updatedAt: nil
        ))
    }
    .environmentObject(AuthManager())
}
