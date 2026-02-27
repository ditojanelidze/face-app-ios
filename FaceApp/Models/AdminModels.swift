import Foundation

// MARK: - Admin Venue

struct AdminVenue: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let address: String?
    let stats: VenueStats?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, name, description, address, stats
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct VenueStats: Codable {
    let totalEvents: Int
    let upcomingEvents: Int
    let pendingApprovals: Int
    let approvedUsers: Int

    enum CodingKeys: String, CodingKey {
        case totalEvents = "total_events"
        case upcomingEvents = "upcoming_events"
        case pendingApprovals = "pending_approvals"
        case approvedUsers = "approved_users"
    }
}

struct AdminVenuesResponse: Codable {
    let venues: [AdminVenue]
}

struct AdminVenueResponse: Codable {
    let venue: AdminVenue
}

// MARK: - Admin Approval

struct AdminApprovalUser: Codable, Identifiable {
    let id: Int
    let fullName: String
    let phoneNumber: String

    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case phoneNumber = "phone_number"
    }
}

struct AdminApprovalEvent: Codable, Identifiable {
    let id: Int
    let name: String
    let dateTime: Date

    enum CodingKeys: String, CodingKey {
        case id, name
        case dateTime = "date_time"
    }
}

struct AdminApproval: Codable, Identifiable {
    let id: Int
    let user: AdminApprovalUser
    let event: AdminApprovalEvent?
    let approvalType: String
    let status: String
    let active: Bool
    let qrUsed: Bool
    let expiresAt: Date?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, user, event, status, active
        case approvalType = "approval_type"
        case qrUsed = "qr_used"
        case expiresAt = "expires_at"
        case createdAt = "created_at"
    }

    var isPending: Bool { status == "pending" }
    var isApproved: Bool { status == "approved" }
    var isRejected: Bool { status == "rejected" }

    var statusDisplayName: String {
        switch status {
        case "approved": return "Approved"
        case "rejected": return "Rejected"
        default: return "Pending"
        }
    }

    var approvalTypeLabel: String {
        approvalType == "event_specific" ? "Event Access" : "Global Access"
    }
}

struct AdminApprovalsResponse: Codable {
    let approvals: [AdminApproval]
}

struct AdminApprovalResponse: Codable {
    let message: String?
    let approval: AdminApproval
}
