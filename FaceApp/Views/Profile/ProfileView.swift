import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showingImagePicker = false
    @State private var showingIdCardPicker = false
    @State private var selectedImage: PhotosPickerItem?
    @State private var selectedIdCard: PhotosPickerItem?
    @State private var showingEditProfile = false
    @State private var showingLogoutAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    profileHeader

                    // Verification Status
                    verificationStatus

                    // Social Links
                    if let user = authManager.currentUser {
                        socialLinksSection(user: user)
                    }

                    // Actions
                    actionsSection

                    Spacer(minLength: 100)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") {
                        showingEditProfile = true
                    }
                }
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
            .alert("Logout", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    Task {
                        await authManager.logout()
                    }
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Profile Photo
            PhotosPicker(selection: $selectedImage, matching: .images) {
                ZStack {
                    if let photoUrl = authManager.currentUser?.profilePhotoUrl,
                       let url = URL(string: photoUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            profilePlaceholder
                        }
                    } else {
                        profilePlaceholder
                    }
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 4)
                        .shadow(radius: 4)
                )
                .overlay(
                    Image(systemName: "camera.fill")
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                        .offset(x: 40, y: 40)
                )
            }
            .onChange(of: selectedImage) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        try? await authManager.uploadProfilePhoto(imageData: data)
                    }
                }
            }

            // Name
            if let user = authManager.currentUser {
                Text(user.fullName)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(user.phoneNumber)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical)
    }

    private var profilePlaceholder: some View {
        ZStack {
            Circle()
                .fill(Color(.systemGray5))
            Image(systemName: "person.fill")
                .font(.system(size: 50))
                .foregroundStyle(.gray)
        }
    }

    // MARK: - Verification Status

    private var verificationStatus: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Verification Status")
                    .font(.headline)
                Spacer()
            }

            VStack(spacing: 8) {
                // Phone Verified
                statusRow(
                    icon: "checkmark.circle.fill",
                    iconColor: .green,
                    title: "Phone Verified",
                    isComplete: authManager.currentUser?.phoneVerified ?? false
                )

                // Profile Photo
                HStack {
                    statusRow(
                        icon: authManager.currentUser?.profilePhotoUrl != nil ? "checkmark.circle.fill" : "circle",
                        iconColor: authManager.currentUser?.profilePhotoUrl != nil ? .green : .gray,
                        title: "Profile Photo",
                        isComplete: authManager.currentUser?.profilePhotoUrl != nil
                    )

                    if authManager.currentUser?.profilePhotoUrl == nil {
                        PhotosPicker(selection: $selectedImage, matching: .images) {
                            Text("Add")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.blue)
                        }
                    }
                }

                // ID Card
                HStack {
                    statusRow(
                        icon: authManager.currentUser?.idCardImageUrl != nil ? "checkmark.circle.fill" : "circle",
                        iconColor: authManager.currentUser?.idCardImageUrl != nil ? .green : .gray,
                        title: "ID Card",
                        isComplete: authManager.currentUser?.idCardImageUrl != nil
                    )

                    if authManager.currentUser?.idCardImageUrl == nil {
                        PhotosPicker(selection: $selectedIdCard, matching: .images) {
                            Text("Add")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.blue)
                        }
                        .onChange(of: selectedIdCard) { _, newValue in
                            Task {
                                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                    try? await authManager.uploadIdCard(imageData: data)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func statusRow(icon: String, iconColor: Color, title: String, isComplete: Bool) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
            Text(title)
                .font(.subheadline)
            Spacer()
        }
    }

    // MARK: - Social Links

    private func socialLinksSection(user: User) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("Social Links")
                    .font(.headline)
                Spacer()
            }

            VStack(spacing: 0) {
                if let facebook = user.socialLinks?.facebook, !facebook.isEmpty {
                    socialLinkRow(icon: "link", title: "Facebook", value: facebook)
                    Divider()
                }
                if let instagram = user.socialLinks?.instagram, !instagram.isEmpty {
                    socialLinkRow(icon: "camera", title: "Instagram", value: instagram)
                    Divider()
                }
                if let linkedin = user.socialLinks?.linkedin, !linkedin.isEmpty {
                    socialLinkRow(icon: "briefcase", title: "LinkedIn", value: linkedin)
                }

                if user.socialLinks?.facebook == nil &&
                   user.socialLinks?.instagram == nil &&
                   user.socialLinks?.linkedin == nil {
                    HStack {
                        Text("No social links added")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding()
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func socialLinkRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
            Text(title)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding()
    }

    // MARK: - Actions

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button {
                showingLogoutAlert = true
            } label: {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Logout")
                    Spacer()
                }
                .foregroundStyle(.red)
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager())
}
