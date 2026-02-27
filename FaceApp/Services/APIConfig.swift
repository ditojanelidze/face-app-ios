import Foundation

enum APIConfig {
    // Change this to your server URL
    static let baseURL = "http://localhost:3000"
    static let apiVersion = "/api"

    static var fullBaseURL: String {
        baseURL + apiVersion
    }

    enum Endpoint {
        // Auth
        case register
        case confirmRegistration
        case login
        case confirmLogin
        case refresh
        case logout

        // Profile
        case profile
        case uploadPhoto
        case uploadIdCard
        case profileApprovals
        case activeApprovals

        // Venues
        case venues
        case venue(id: Int)
        case venueEvents(id: Int)

        // Approvals
        case approvals
        case approval(id: Int)
        case approvalQRCode(id: Int)

        // Admin Venues
        case adminVenues
        case adminVenue(id: Int)

        // Admin Approvals
        case adminApprovals(venueId: Int)
        case adminPendingApprovals(venueId: Int)
        case adminApproval(venueId: Int, id: Int)
        case adminApproveApproval(venueId: Int, id: Int)
        case adminRejectApproval(venueId: Int, id: Int)

        var path: String {
            switch self {
            case .register:
                return "/auth/register"
            case .confirmRegistration:
                return "/auth/confirm_registration"
            case .login:
                return "/auth/login"
            case .confirmLogin:
                return "/auth/confirm_login"
            case .refresh:
                return "/auth/refresh"
            case .logout:
                return "/auth/logout"
            case .profile:
                return "/profile"
            case .uploadPhoto:
                return "/profile/upload_photo"
            case .uploadIdCard:
                return "/profile/upload_id_card"
            case .profileApprovals:
                return "/profile/approvals"
            case .activeApprovals:
                return "/profile/active_approvals"
            case .venues:
                return "/venues"
            case .venue(let id):
                return "/venues/\(id)"
            case .venueEvents(let id):
                return "/venues/\(id)/events"
            case .approvals:
                return "/approvals"
            case .approval(let id):
                return "/approvals/\(id)"
            case .approvalQRCode(let id):
                return "/approvals/\(id)/qr_code"
            case .adminVenues:
                return "/admin/venues"
            case .adminVenue(let id):
                return "/admin/venues/\(id)"
            case .adminApprovals(let venueId):
                return "/admin/venues/\(venueId)/approvals"
            case .adminPendingApprovals(let venueId):
                return "/admin/venues/\(venueId)/approvals/pending"
            case .adminApproval(let venueId, let id):
                return "/admin/venues/\(venueId)/approvals/\(id)"
            case .adminApproveApproval(let venueId, let id):
                return "/admin/venues/\(venueId)/approvals/\(id)/approve"
            case .adminRejectApproval(let venueId, let id):
                return "/admin/venues/\(venueId)/approvals/\(id)/reject"
            }
        }

        var url: URL? {
            URL(string: APIConfig.fullBaseURL + path)
        }
    }
}
