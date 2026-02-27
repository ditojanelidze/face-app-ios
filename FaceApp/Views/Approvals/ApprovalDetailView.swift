import SwiftUI
import CoreImage.CIFilterBuiltins

struct ApprovalDetailView: View {
    let approval: Approval
    @StateObject private var approvalService = ApprovalService()
    @State private var qrCodeData: String?
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Status Header
                statusHeader

                // QR Code Section
                if approval.status == .approved {
                    qrCodeSection
                }

                // Details
                detailsSection

                // Info
                infoSection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Pass Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadQRCode()
        }
    }

    // MARK: - Status Header

    private var statusHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.1))
                    .frame(width: 80, height: 80)

                Image(systemName: approval.statusIcon)
                    .font(.system(size: 36))
                    .foregroundStyle(statusColor)
            }

            VStack(spacing: 4) {
                Text(statusTitle)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(statusSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical)
    }

    private var statusTitle: String {
        switch approval.status {
        case .pending:
            return "Pending Review"
        case .approved:
            return approval.qrUsed ? "Pass Used" : "Access Granted"
        case .rejected:
            return "Request Declined"
        }
    }

    private var statusSubtitle: String {
        switch approval.status {
        case .pending:
            return "Your request is being reviewed by the venue"
        case .approved:
            return approval.qrUsed ? "This pass has already been scanned" : "Show this QR code at entry"
        case .rejected:
            return "Unfortunately, your request was not approved"
        }
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

    // MARK: - QR Code Section

    private var qrCodeSection: some View {
        VStack(spacing: 16) {
            if isLoading {
                ProgressView()
                    .frame(width: 250, height: 250)
            } else if let qrData = qrCodeData ?? approval.qrCodeData {
                // QR Code
                QRCodeView(data: qrData)
                    .frame(width: 250, height: 250)
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)

                if approval.qrUsed {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text("This QR code has been used")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    // MARK: - Details Section

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)

            VStack(spacing: 0) {
                detailRow(icon: "building.2", title: "Venue", value: approval.venue.name)
                Divider().padding(.leading, 40)

                detailRow(
                    icon: approval.approvalType == .global ? "globe" : "calendar",
                    title: "Access Type",
                    value: approval.approvalType == .global ? "Global" : "Event Specific"
                )

                if let event = approval.event {
                    Divider().padding(.leading, 40)
                    detailRow(icon: "calendar", title: "Event", value: event.name)
                }

                if let expiresAt = approval.expiresAt {
                    Divider().padding(.leading, 40)
                    detailRow(icon: "clock", title: "Expires", value: formatDate(expiresAt))
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
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
        .padding()
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // MARK: - Info Section

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundStyle(.blue)
                Text("How it works")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Text("Present this QR code to the venue staff at entry. They will scan it to verify your access. Each QR code can typically only be used once.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func loadQRCode() async {
        isLoading = true
        if approval.status == .approved {
            qrCodeData = try? await approvalService.getQRCode(approvalId: approval.id)
        }
        isLoading = false
    }
}

// MARK: - QR Code View

struct QRCodeView: View {
    let data: String

    var body: some View {
        if let qrImage = generateQRCode(from: data) {
            Image(uiImage: qrImage)
                .interpolation(.none)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
        } else {
            Image(systemName: "qrcode")
                .font(.system(size: 100))
                .foregroundStyle(.gray)
        }
    }

    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()

        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else { return nil }

        let scale = 10.0
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let scaledImage = outputImage.transformed(by: transform)

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}

#Preview {
    NavigationStack {
        ApprovalDetailView(approval: Approval(
            id: 1,
            venue: ApprovalVenue(id: 1, name: "Sky Bar"),
            event: nil,
            approvalType: .global,
            status: .approved,
            active: true,
            qrUsed: false,
            qrCodeData: "test-qr-code-data",
            expiresAt: nil,
            createdAt: Date()
        ))
    }
}
