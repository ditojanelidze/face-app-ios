import Foundation
import SwiftUI

@MainActor
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var error: String?

    private let api = APIService.shared
    private let keychain = KeychainService.shared

    init() {
        checkAuthState()
    }

    private func checkAuthState() {
        guard keychain.get(key: "accessToken") != nil else { return }
        isAuthenticated = true
        Task { await fetchProfile() }
    }

    // MARK: - Registration

    // Step 1: submit name + phone → OTP sent via SMS
    func register(phoneNumber: String, firstName: String, lastName: String) async throws {
        isLoading = true
        error = nil
        defer { isLoading = false }

        struct RegisterRequest: Encodable {
            let phoneNumber: String
            let firstName: String
            let lastName: String
        }

        let _: MessageResponse = try await api.request(
            endpoint: .register,
            method: "POST",
            body: RegisterRequest(phoneNumber: phoneNumber, firstName: firstName, lastName: lastName)
        )
    }

    // Step 2: submit OTP → account activated, tokens returned
    func confirmRegistration(phoneNumber: String, smsCode: String) async throws {
        isLoading = true
        error = nil
        defer { isLoading = false }

        struct ConfirmRequest: Encodable {
            let phoneNumber: String
            let smsCode: String
        }

        let response: AuthResponse = try await api.request(
            endpoint: .confirmRegistration,
            method: "POST",
            body: ConfirmRequest(phoneNumber: phoneNumber, smsCode: smsCode)
        )

        handleAuthResponse(response)
    }

    // MARK: - Login

    // Step 1: submit phone → OTP sent via SMS
    func login(phoneNumber: String) async throws {
        isLoading = true
        error = nil
        defer { isLoading = false }

        struct LoginRequest: Encodable {
            let phoneNumber: String
        }

        let _: MessageResponse = try await api.request(
            endpoint: .login,
            method: "POST",
            body: LoginRequest(phoneNumber: phoneNumber)
        )
    }

    // Step 2: submit OTP → tokens returned
    func confirmLogin(phoneNumber: String, smsCode: String, deviceInfo: String? = nil) async throws {
        isLoading = true
        error = nil
        defer { isLoading = false }

        struct ConfirmLoginRequest: Encodable {
            let phoneNumber: String
            let smsCode: String
            let deviceInfo: String?
        }

        let response: AuthResponse = try await api.request(
            endpoint: .confirmLogin,
            method: "POST",
            body: ConfirmLoginRequest(phoneNumber: phoneNumber, smsCode: smsCode, deviceInfo: deviceInfo)
        )

        handleAuthResponse(response)
    }

    // MARK: - Session

    func logout() async {
        isLoading = true
        defer { isLoading = false }

        if let refreshToken = keychain.get(key: "refreshToken") {
            struct LogoutRequest: Encodable {
                let refreshToken: String
            }

            let _: MessageResponse? = try? await api.request(
                endpoint: .logout,
                method: "DELETE",
                body: LogoutRequest(refreshToken: refreshToken)
            )
        }

        keychain.clearAll()
        currentUser = nil
        isAuthenticated = false
    }

    private func handleAuthResponse(_ response: AuthResponse) {
        if let accessToken = response.accessToken {
            keychain.save(key: "accessToken", value: accessToken)
        }
        if let refreshToken = response.refreshToken {
            keychain.save(key: "refreshToken", value: refreshToken)
        }
        if let user = response.user {
            currentUser = user
        }
        isAuthenticated = true
    }

    // MARK: - Profile

    func fetchProfile() async {
        do {
            let response: UserResponse = try await api.request(
                endpoint: .profile,
                authenticated: true
            )
            currentUser = response.user
        } catch {
            if case APIError.unauthorized = error {
                await logout()
            }
        }
    }

    func updateProfile(firstName: String?, lastName: String?, socialLinks: [String: String]?) async throws {
        isLoading = true
        error = nil
        defer { isLoading = false }

        struct ProfileUpdateRequest: Codable {
            let profile: ProfileData
            struct ProfileData: Codable {
                let firstName: String?
                let lastName: String?
                let facebookUrl: String?
                let instagramUrl: String?
                let linkedinUrl: String?
                enum CodingKeys: String, CodingKey {
                    case firstName = "first_name"
                    case lastName = "last_name"
                    case facebookUrl = "facebook_url"
                    case instagramUrl = "instagram_url"
                    case linkedinUrl = "linkedin_url"
                }
            }
        }

        let request = ProfileUpdateRequest(profile: .init(
            firstName: firstName,
            lastName: lastName,
            facebookUrl: socialLinks?["facebook"],
            instagramUrl: socialLinks?["instagram"],
            linkedinUrl: socialLinks?["linkedin"]
        ))

        let response: UserResponse = try await api.request(
            endpoint: .profile,
            method: "PATCH",
            body: request,
            authenticated: true
        )

        currentUser = response.user
    }

    func uploadProfilePhoto(imageData: Data) async throws {
        isLoading = true
        error = nil
        defer { isLoading = false }

        _ = try await api.uploadFile(
            endpoint: .uploadPhoto,
            fileData: imageData,
            fileName: "photo.jpg",
            fieldName: "photo",
            mimeType: "image/jpeg"
        )

        await fetchProfile()
    }

    func uploadIdCard(imageData: Data) async throws {
        isLoading = true
        error = nil
        defer { isLoading = false }

        _ = try await api.uploadFile(
            endpoint: .uploadIdCard,
            fileData: imageData,
            fileName: "id_card.jpg",
            fieldName: "id_card",
            mimeType: "image/jpeg"
        )

        await fetchProfile()
    }
}
