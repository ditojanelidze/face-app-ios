import Foundation

struct Event: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let dateTime: Date
    let allowGlobalApproval: Bool
    let upcoming: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, description
        case dateTime = "date_time"
        case allowGlobalApproval = "allow_global_approval"
        case upcoming
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: dateTime)
    }

    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: dateTime)
    }

    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: dateTime)
    }
}
