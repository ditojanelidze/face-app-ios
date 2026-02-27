import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var facebookUrl = ""
    @State private var instagramUrl = ""
    @State private var linkedinUrl = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Information") {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                }

                Section("Social Links (Optional)") {
                    HStack {
                        Image(systemName: "link")
                            .foregroundStyle(.blue)
                        TextField("Facebook URL", text: $facebookUrl)
                            .textContentType(.URL)
                            .autocapitalization(.none)
                    }

                    HStack {
                        Image(systemName: "camera")
                            .foregroundStyle(.pink)
                        TextField("Instagram URL", text: $instagramUrl)
                            .textContentType(.URL)
                            .autocapitalization(.none)
                    }

                    HStack {
                        Image(systemName: "briefcase")
                            .foregroundStyle(.blue)
                        TextField("LinkedIn URL", text: $linkedinUrl)
                            .textContentType(.URL)
                            .autocapitalization(.none)
                    }
                }

                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProfile()
                    }
                    .disabled(isSaving || firstName.isEmpty || lastName.isEmpty)
                }
            }
            .onAppear {
                loadCurrentProfile()
            }
        }
    }

    private func loadCurrentProfile() {
        guard let user = authManager.currentUser else { return }
        firstName = user.firstName
        lastName = user.lastName
        facebookUrl = user.socialLinks?.facebook ?? ""
        instagramUrl = user.socialLinks?.instagram ?? ""
        linkedinUrl = user.socialLinks?.linkedin ?? ""
    }

    private func saveProfile() {
        isSaving = true
        errorMessage = nil

        Task {
            do {
                var socialLinks: [String: String] = [:]
                if !facebookUrl.isEmpty { socialLinks["facebook"] = facebookUrl }
                if !instagramUrl.isEmpty { socialLinks["instagram"] = instagramUrl }
                if !linkedinUrl.isEmpty { socialLinks["linkedin"] = linkedinUrl }

                try await authManager.updateProfile(
                    firstName: firstName,
                    lastName: lastName,
                    socialLinks: socialLinks.isEmpty ? nil : socialLinks
                )
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
            isSaving = false
        }
    }
}

#Preview {
    EditProfileView()
        .environmentObject(AuthManager())
}
