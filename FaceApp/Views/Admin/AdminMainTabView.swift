import SwiftUI

struct AdminMainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            AdminVenuesView()
                .tabItem {
                    Label("My Venues", systemImage: "building.2")
                }
                .tag(0)

            AdminProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
                .tag(1)
        }
        .tint(.primary)
    }
}

#Preview {
    AdminMainTabView()
        .environmentObject(AuthManager())
}
