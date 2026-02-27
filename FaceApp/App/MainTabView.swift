import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            VenuesView()
                .tabItem {
                    Label("Venues", systemImage: "building.2")
                }
                .tag(0)

            ApprovalsView()
                .tabItem {
                    Label("My Passes", systemImage: "qrcode")
                }
                .tag(1)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
                .tag(2)
        }
        .tint(.primary)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthManager())
}
