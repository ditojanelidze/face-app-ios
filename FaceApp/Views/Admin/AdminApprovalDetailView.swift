import SwiftUI

struct AdminApprovalDetailView: View {
    let approval: AdminApproval
    let venueId: Int
    let onUpdate: (AdminApproval) -> Void

    @StateObject private var adminService = AdminService()
    @State private var currentApproval: AdminApproval
    @State private var isActioning = false
    @State private var actionError: String?
    @Environment(\.dismiss) private var dismiss

    init(approval: AdminApproval, venueId: Int, onUpdate: @escaping (AdminApproval) -> Void) {
        self.approval = approval
        self.venueId = venueId
        self.onUpdate = onUpdate
        _currentApproval = State(initialValue: approval)
    }

    var body: some View {
        List {
            // User Section
            Section("Applicant") {
                LabeledContent("Name", value: currentApproval.user.fullName)
                LabeledContent("Phone", value: currentApproval.user.phoneNumber)
            }

            // Request Details
            Section("Request Details") {
                LabeledContent("Access Type", value: currentApproval.approvalTypeLabel)
                if let event = currentApproval.event {
                    LabeledContent("Event", value: event.name)
                }
                LabeledContent("Submitted", value: currentApproval.createdAt.formatted(date: .abbreviated, time: .shortened))
            }

            // Status
            Section("Status") {
                HStack {
                    Text("Current Status")
                    Spacer()
                    StatusBadge(status: currentApproval.status)
                }
                if let expiresAt = currentApproval.expiresAt {
                    LabeledContent("Expires", value: expiresAt.formatted(date: .abbreviated, time: .omitted))
                }
            }

            // Actions (only for pending)
            if currentApproval.isPending {
                Section {
                    if let error = actionError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    Button {
                        Task { await handleApprove() }
                    } label: {
                        HStack {
                            Spacer()
                            if isActioning {
                                ProgressView().tint(.white)
                            } else {
                                Label("Approve", systemImage: "checkmark.circle.fill")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                    .foregroundStyle(.white)
                    .listRowBackground(Color.green)
                    .disabled(isActioning)

                    Button {
                        Task { await handleReject() }
                    } label: {
                        HStack {
                            Spacer()
                            Label("Reject", systemImage: "xmark.circle.fill")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                    .foregroundStyle(.white)
                    .listRowBackground(Color.red)
                    .disabled(isActioning)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Approval Request")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func handleApprove() async {
        isActioning = true
        actionError = nil
        defer { isActioning = false }

        do {
            let updated = try await adminService.approveApproval(venueId: venueId, approvalId: currentApproval.id)
            currentApproval = updated
            onUpdate(updated)
        } catch {
            actionError = error.localizedDescription
        }
    }

    private func handleReject() async {
        isActioning = true
        actionError = nil
        defer { isActioning = false }

        do {
            let updated = try await adminService.rejectApproval(venueId: venueId, approvalId: currentApproval.id)
            currentApproval = updated
            onUpdate(updated)
        } catch {
            actionError = error.localizedDescription
        }
    }
}
