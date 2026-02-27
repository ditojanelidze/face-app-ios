import Foundation

@MainActor
class AdminService: ObservableObject {
    @Published var venues: [AdminVenue] = []
    @Published var approvals: [AdminApproval] = []
    @Published var isLoading = false
    @Published var error: String?

    private let api = APIService.shared

    func fetchVenues() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let response: AdminVenuesResponse = try await api.request(
                endpoint: .adminVenues,
                authenticated: true
            )
            venues = response.venues
        } catch {
            self.error = error.localizedDescription
        }
    }

    func fetchVenueDetail(id: Int) async throws -> AdminVenue {
        let response: AdminVenueResponse = try await api.request(
            endpoint: .adminVenue(id: id),
            authenticated: true
        )
        return response.venue
    }

    func fetchApprovals(venueId: Int, pendingOnly: Bool = false) async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let endpoint: APIConfig.Endpoint = pendingOnly
                ? .adminPendingApprovals(venueId: venueId)
                : .adminApprovals(venueId: venueId)
            let response: AdminApprovalsResponse = try await api.request(
                endpoint: endpoint,
                authenticated: true
            )
            approvals = response.approvals
        } catch {
            self.error = error.localizedDescription
        }
    }

    func approveApproval(venueId: Int, approvalId: Int) async throws -> AdminApproval {
        let response: AdminApprovalResponse = try await api.request(
            endpoint: .adminApproveApproval(venueId: venueId, id: approvalId),
            method: "POST",
            authenticated: true
        )
        return response.approval
    }

    func rejectApproval(venueId: Int, approvalId: Int) async throws -> AdminApproval {
        let response: AdminApprovalResponse = try await api.request(
            endpoint: .adminRejectApproval(venueId: venueId, id: approvalId),
            method: "POST",
            authenticated: true
        )
        return response.approval
    }
}
