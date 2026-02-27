import Foundation

@MainActor
class ApprovalService: ObservableObject {
    @Published var approvals: [Approval] = []
    @Published var activeApprovals: [Approval] = []
    @Published var isLoading = false
    @Published var error: String?

    private let api = APIService.shared

    func fetchApprovals() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let response: ApprovalsResponse = try await api.request(
                endpoint: .approvals,
                authenticated: true
            )
            approvals = response.approvals
            activeApprovals = approvals.filter { $0.active }
        } catch {
            self.error = error.localizedDescription
        }
    }

    func fetchApproval(id: Int) async throws -> Approval {
        let response: ApprovalResponse = try await api.request(
            endpoint: .approval(id: id),
            authenticated: true
        )
        return response.approval
    }

    func requestApproval(venueId: Int, eventId: Int? = nil, type: ApprovalType) async throws -> Approval {
        let request = CreateApprovalRequest(
            approval: ApprovalRequest(
                venueId: venueId,
                eventId: eventId,
                approvalType: type.rawValue
            )
        )

        let response: ApprovalResponse = try await api.request(
            endpoint: .approvals,
            method: "POST",
            body: request,
            authenticated: true
        )

        await fetchApprovals()
        return response.approval
    }

    func getQRCode(approvalId: Int) async throws -> String? {
        let response: QRCodeResponse = try await api.request(
            endpoint: .approvalQRCode(id: approvalId),
            authenticated: true
        )
        return response.qrCodeData
    }
}
