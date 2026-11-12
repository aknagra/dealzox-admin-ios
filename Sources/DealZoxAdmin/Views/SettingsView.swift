import SwiftUI

public struct SettingsView: View {
    @ObservedObject var service = SupabaseService.shared
    @State private var isStoreOpen = true
    @State private var isUpdating = false

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Store Status (dealzox.in)")) {
                    Toggle("Store Open & Active", isOn: Binding(
                        get: { service.siteSettings?.storeOpen ?? true },
                        set: { newValue in
                            isUpdating = true
                            Task {
                                _ = await service.toggleStoreOpen(isOpen: newValue)
                                isUpdating = false
                            }
                        }
                    ))
                    .disabled(isUpdating)

                    Text(service.siteSettings?.storeOpen == true ?
                         "Website par catalog aur checkout active hai. Customers orders place kar sakte hain." :
                         "Website par catalog empty dikhega aur checkout block rahega. Naye orders paused hain.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section(header: Text("Payment & Store Details")) {
                    if let upi = service.siteSettings?.upiId {
                        HStack {
                            Text("UPI ID")
                            Spacer()
                            Text(upi)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    if let pin = service.siteSettings?.adminPin {
                        HStack {
                            Text("Current Admin PIN")
                            Spacer()
                            Text(pin)
                                .fontDesign(.monospaced)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                    }
                }

                Section(header: Text("Quick Links")) {
                    if let tg = service.siteSettings?.telegramUrl, let url = URL(string: tg) {
                        Link(destination: url) {
                            Label("Telegram Channel", systemImage: "paperplane")
                        }
                    }

                    if let ig = service.siteSettings?.instagramUrl, let url = URL(string: ig) {
                        Link(destination: url) {
                            Label("Instagram Store", systemImage: "camera")
                        }
                    }
                }

                Section(footer: Text("DealZox Admin for iOS • Built with SwiftPM & xtool")) {}
            }
            .navigationTitle("Store Settings")
            .task {
                await service.fetchSiteSettings()
            }
        }
    }
}
