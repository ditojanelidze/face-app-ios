import Foundation

struct Venue: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let address: String?
    let createdAt: Date?
    let updatedAt: Date?
    let upcomingEvents: [Event]?

    enum CodingKeys: String, CodingKey {
        case id, name, description, address
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case upcomingEvents = "upcoming_events"
    }
}

struct VenuesResponse: Codable {
    let venues: [Venue]
}

struct VenueResponse: Codable {
    let venue: Venue
}

struct EventsResponse: Codable {
    let events: [Event]
}
