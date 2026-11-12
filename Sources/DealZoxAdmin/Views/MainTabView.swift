import SwiftUI

public struct MainTabView: View {
    @ObservedObject var service = SupabaseService.shared

    public init() {}

    private var pendingCount: Int {
        service.orders.filter { $0.isPending }.count
    }

    public var body: some View {
        TabView {
            OrdersView()
                .tabItem {
                    Label("Orders", systemImage: "cart.fill")
                }
                .badge(pendingCount > 0 ? "\(pendingCount)" : nil)

            LeadsView()
                .tabItem {
                    Label("Leads", systemImage: "person.2.fill")
                }

            ProductsView()
                .tabItem {
                    Label("Products", systemImage: "tag.fill")
                }

            BotControlView()
                .tabItem {
                    Label("Bot", systemImage: "waveform.path.badge.plus")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}
