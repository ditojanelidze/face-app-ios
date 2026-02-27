import Foundation

@MainActor
class VenueService: ObservableObject {
    @Published var venues: [Venue] = []
    @Published var isLoading = false
    @Published var error: String?

    private let api = APIService.shared

    func fetchVenues() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let response: VenuesResponse = try await api.request(
                endpoint: .venues,
                authenticated: true
            )
            venues = response.venues
        } catch {
            self.error = error.localizedDescription
        }
    }

    func fetchVenue(id: Int) async throws -> Venue {
        let response: VenueResponse = try await api.request(
            endpoint: .venue(id: id),
            authenticated: true
        )
        return response.venue
    }

    func fetchEvents(venueId: Int) async throws -> [Event] {
        let response: EventsResponse = try await api.request(
            endpoint: .venueEvents(id: venueId),
            authenticated: true
        )
        return response.events
    }
}
