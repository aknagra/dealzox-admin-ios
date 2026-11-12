import Foundation

@MainActor
public final class SupabaseService: ObservableObject {
    public static let shared = SupabaseService()

    private let baseUrl = "https://epjatpifzcbcttcijjha.supabase.co/rest/v1"
    private let apiKey = "sb_publishable_tr96j7tJFX4OSAwn8h7OMA_OaU4RT_Y"

    @Published public var orders: [Order] = []
    @Published public var leads: [Lead] = []
    @Published public var products: [Product] = []
    @Published public var siteSettings: SiteSettings?
    @Published public var isLoading = false
    @Published public var errorMessage: String?

    private var headers: [String: String] {
        [
            "apikey": apiKey,
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json",
            "Prefer": "return=representation"
        ]
    }

    // MARK: - Orders
    public func fetchOrders() async {
        isLoading = true
        errorMessage = nil
        do {
            let url = URL(string: "\(baseUrl)/orders?select=*&order=id.desc&limit=60")!
            var request = URLRequest(url: url)
            headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode([Order].self, from: data)
            self.orders = decoded
        } catch {
            self.errorMessage = "Failed to load orders: \(error.localizedDescription)"
        }
        isLoading = false
    }

    public func updateOrderStatus(orderId: Int, newStatus: String) async -> Bool {
        do {
            let url = URL(string: "\(baseUrl)/orders?id=eq.\(orderId)")!
            var request = URLRequest(url: url)
            request.httpMethod = "PATCH"
            headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

            let body = ["status": newStatus]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (_, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) {
                if let index = orders.firstIndex(where: { $0.id == orderId }) {
                    orders[index].status = newStatus
                }
                return true
            }
        } catch {
            self.errorMessage = "Status update error: \(error.localizedDescription)"
        }
        return false
    }

    // MARK: - Leads
    public func fetchLeads() async {
        do {
            let url = URL(string: "\(baseUrl)/leads?select=*&order=id.desc&limit=60")!
            var request = URLRequest(url: url)
            headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

            let (data, _) = try await URLSession.shared.data(for: request)
            self.leads = try JSONDecoder().decode([Lead].self, from: data)
        } catch {
            self.errorMessage = "Failed to load leads: \(error.localizedDescription)"
        }
    }

    public func deleteLead(leadId: Int) async -> Bool {
        do {
            let url = URL(string: "\(baseUrl)/leads?id=eq.\(leadId)")!
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

            let (_, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) {
                leads.removeAll { $0.id == leadId }
                return true
            }
        } catch {
            self.errorMessage = "Delete lead failed: \(error.localizedDescription)"
        }
        return false
    }

    // MARK: - Products & Stock
    public func fetchProducts() async {
        do {
            let url = URL(string: "\(baseUrl)/products?select=*&order=id.asc")!
            var request = URLRequest(url: url)
            headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

            let (data, _) = try await URLSession.shared.data(for: request)
            self.products = try JSONDecoder().decode([Product].self, from: data)
        } catch {
            self.errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
    }

    // MARK: - Site Settings
    public func fetchSiteSettings() async {
        do {
            let url = URL(string: "\(baseUrl)/site_settings?select=*&id=eq.1")!
            var request = URLRequest(url: url)
            headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

            let (data, _) = try await URLSession.shared.data(for: request)
            let items = try JSONDecoder().decode([SiteSettings].self, from: data)
            self.siteSettings = items.first
        } catch {
            self.errorMessage = "Failed to load settings: \(error.localizedDescription)"
        }
    }

    public func toggleStoreOpen(isOpen: Bool) async -> Bool {
        do {
            let url = URL(string: "\(baseUrl)/site_settings?id=eq.1")!
            var request = URLRequest(url: url)
            request.httpMethod = "PATCH"
            headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

            let body: [String: Any] = ["store_open": isOpen]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (_, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) {
                siteSettings?.storeOpen = isOpen
                return true
            }
        } catch {
            self.errorMessage = "Toggle store failed: \(error.localizedDescription)"
        }
        return false
    }
}
