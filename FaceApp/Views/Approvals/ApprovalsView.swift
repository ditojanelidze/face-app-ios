import SwiftUI

struct ApprovalsView: View {
    @StateObject private var approvalService = ApprovalService()
    @State private var selectedSegment = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segment Control
                Picker("Filter", selection: $selectedSegment) {
                    Text("Active").tag(0)
                    Text("All").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                // Content
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredApprovals) { approval in
                            NavigationLink(destination: ApprovalDetailView(approval: approval)) {
                                ApprovalCard(approval: approval)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
                .overlay {
                    if approvalService.isLoading && approvalService.approvals.isEmpty {
                        ProgressView()
                    } else if filteredApprovals.isEmpty {
                        emptyState
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("My Passes")
            .refreshable {
                await approvalService.fetchApprovals()
            }
            .task {
                await approvalService.fetchApprovals()
            }
        }
    }

    private var filteredApprovals: [Approval] {
        if selectedSegment == 0 {
            return approvalService.activeApprovals
        }
        return approvalService.approvals
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "qrcode")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Passes Yet")
                .font(.title2)
                .fontWeight(.bold)

            Text(selectedSegment == 0
                 ? "Request access to venues to get your passes"
                 : "You haven't requested any venue access yet")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Approval Card

struct ApprovalCard: View {
    let approval: Approval

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Status Icon
                statusIcon

                VStack(alignment: .leading, spacing: 4) {
                    Text(approval.venue.name)
                        .font(.headline)

                    HStack(spacing: 4) {
                        Image(systemName: approval.approvalType == .global ? "globe" : "calendar")
                            .font(.caption2)
                        Text(approval.approvalType == .global ? "Global Access" : "Event Access")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }

                Spacer()

                // Status Badge
                statusBadge
            }

            if let event = approval.event {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text(event.name)
                        .font(.subheadline)
                }
                .foregroundStyle(.secondary)
            }

            // QR Code Preview for approved
            if approval.status == .approved && !approval.qrUsed {
                HStack {
                    Image(systemName: "qrcode")
                        .foregroundStyle(.blue)
                    Text("Tap to view QR code")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 4)
            }

            if approval.qrUsed {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Already used")
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

    private var statusIcon: some View {
        ZStack {
            Circle()
                .fill(statusColor.opacity(0.1))
                .frame(width: 44, height: 44)

            Image(systemName: approval.statusIcon)
                .foregroundStyle(statusColor)
        }
    }

    private var statusBadge: some View {
        Text(approval.status.rawValue.capitalized)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(statusColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(statusColor.opacity(0.1))
            .clipShape(Capsule())
    }

    private var statusColor: Color {
        switch approval.status {
        case .pending:
            return .orange
        case .approved:
            return .green
        case .rejected:
            return .red
        }
    }
}

#Preview {
    ApprovalsView()
}
