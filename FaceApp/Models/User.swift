import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let firstName: String
    let lastName: String
    let phoneNumber: String
    let phoneVerified: Bool
    let role: String
    let profileComplete: Bool?
    let socialLinks: SocialLinks?
    let profilePhotoUrl: String?
    let idCardImageUrl: String?
    let createdAt: Date?
    let updatedAt: Date?

    var fullName: String {
        "\(firstName) \(lastName)"
    }

    var isVenueAdmin: Bool {
        role == "venue_admin"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case phoneNumber = "phone_number"
        case phoneVerified = "phone_verified"
        case role
        case profileComplete = "profile_complete"
        case socialLinks = "social_links"
        case profilePhotoUrl = "profile_photo_url"
        case idCardImageUrl = "id_card_image_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct SocialLinks: Codable {
    let facebook: String?
    let instagram: String?
    let linkedin: String?
}

struct UserResponse: Codable {
    let user: User
}

struct AuthResponse: Codable {
    let message: String?
    let user: User?
    let accessToken: String?
    let refreshToken: String?

    enum CodingKeys: String, CodingKey {
        case message
        case user
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

struct TokenResponse: Codable {
    let accessToken: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

struct MessageResponse: Codable {
    let message: String
}

struct ErrorResponse: Codable {
    let error: String
}

