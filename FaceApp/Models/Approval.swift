import Foundation

enum ApprovalType: String, Codable {
    case global
    case eventSpecific = "event_specific"
}

enum ApprovalStatus: String, Codable {
    case pending
    case approved
    case rejected
}

struct Approval: Codable, Identifiable {
    let id: Int
    let venue: ApprovalVenue
    let event: ApprovalEvent?
    let approvalType: ApprovalType
    let status: ApprovalStatus
    let active: Bool
    let qrUsed: Bool
    let qrCodeData: String?
    let expiresAt: Date?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, venue, event, active, status
        case approvalType = "approval_type"
        case qrUsed = "qr_used"
        case qrCodeData = "qr_code_data"
        case expiresAt = "expires_at"
        case createdAt = "created_at"
    }

    var statusColor: String {
        switch status {
        case .pending:
            return "orange"
        case .approved:
            return "green"
        case .rejected:
            return "red"
        }
    }

    var statusIcon: String {
        switch status {
        case .pending:
            return "clock"
        case .approved:
            return "checkmark.circle.fill"
        case .rejected:
            return "xmark.circle.fill"
        }
    }
}

struct ApprovalVenue: Codable {
    let id: Int
    let name: String
}

struct ApprovalEvent: Codable {
    let id: Int
    let name: String
    let dateTime: Date

    enum CodingKeys: String, CodingKey {
        case id, name
        case dateTime = "date_time"
    }
}

struct ApprovalsResponse: Codable {
    let approvals: [Approval]
}

struct ApprovalResponse: Codable {
    let approval: Approval
    let message: String?
}

struct CreateApprovalRequest: Codable {
    let approval: ApprovalRequest
}

struct ApprovalRequest: Codable {
    let venueId: Int
    let eventId: Int?
    let approvalType: String

    enum CodingKeys: String, CodingKey {
        case venueId = "venue_id"
        case eventId = "event_id"
        case approvalType = "approval_type"
    }
}

struct QRCodeResponse: Codable {
    let qrCodeSvg: String?
    let qrCodeData: String?

    enum CodingKeys: String, CodingKey {
        case qrCodeSvg = "qr_code_svg"
        case qrCodeData = "qr_code_data"
    }
}
