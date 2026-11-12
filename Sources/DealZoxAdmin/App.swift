import SwiftUI

@main
public struct DealZoxAdminApp: App {
    @State private var isAuthenticated = false

    public init() {}

    public var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                MainTabView()
            } else {
                PinView(isAuthenticated: $isAuthenticated)
            }
        }
    }
}
