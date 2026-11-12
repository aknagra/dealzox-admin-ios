import SwiftUI

public struct OrdersView: View {
    @ObservedObject var service = SupabaseService.shared
    @State private var selectedFilter: OrderFilter = .all
    @State private var searchText = ""

    enum OrderFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case pending = "Pending"
        case delivered = "Delivered"
        case rejected = "Rejected"
        var id: String { rawValue }
    }

    public init() {}

    private var filteredOrders: [Order] {
        service.orders.filter { order in
            let matchesFilter: Bool
            switch selectedFilter {
            case .all: matchesFilter = true
            case .pending: matchesFilter = order.isPending
            case .delivered: matchesFilter = order.isDelivered
            case .rejected: matchesFilter = order.isRejected
            }

            guard matchesFilter else { return false }
            if searchText.isEmpty { return true }

            let q = searchText.lowercased()
            return (order.orderId?.lowercased().contains(q) ?? false) ||
                   (order.phone?.contains(q) ?? false) ||
                   (order.utr?.contains(q) ?? false) ||
                   (order.customerName?.lowercased().contains(q) ?? false)
        }
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Picker
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(OrderFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                // List
                if service.isLoading && service.orders.isEmpty {
                    Spacer()
                    ProgressView("Loading orders...")
                    Spacer()
                } else if filteredOrders.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "tray")
                            .font(.system(size: 44))
                            .foregroundColor(.secondary)
                        Text("Koi order nahi mila")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(filteredOrders) { order in
                            OrderCardView(order: order)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await service.fetchOrders()
                    }
                }
            }
            .navigationTitle("Orders (\(filteredOrders.count))")
            .searchable(text: $searchText, prompt: "Search Order ID, Phone, UTR")
            .task {
                await service.fetchOrders()
            }
        }
    }
}

struct OrderCardView: View {
    let order: Order
    @ObservedObject var service = SupabaseService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(order.orderId ?? "N/A")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                StatusBadge(status: order.status)
            }

            Divider()

            HStack {
                Label(order.customerName ?? "Customer", systemImage: "person.fill")
                    .font(.subheadline)
                Spacer()
                if let price = order.totalPrice {
                    Text("₹\(price)")
                        .font(.headline)
                        .foregroundColor(.green)
                }
            }

            if let phone = order.phone {
                HStack {
                    Label(phone, systemImage: "phone.fill")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    Link(destination: URL(string: "https://wa.me/91\(phone)")!) {
                        HStack(spacing: 4) {
                            Image(systemName: "message.fill")
                            Text("WhatsApp")
                        }
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.15))
                        .foregroundColor(.green)
                        .cornerRadius(6)
                    }
                }
            }

            if let utr = order.utr, !utr.isEmpty {
                Text("UTR: \(utr)")
                    .font(.caption)
                    .fontDesign(.monospaced)
                    .foregroundColor(.secondary)
            }

            if let code = order.deliveredCodes ?? order.code, !code.isEmpty {
                Text("Code: \(code)")
                    .font(.caption)
                    .fontDesign(.monospaced)
                    .padding(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(6)
            }

            // Actions for Pending Orders
            if order.isPending {
                HStack(spacing: 12) {
                    Button(action: {
                        Task {
                            _ = await service.updateOrderStatus(orderId: order.id, newStatus: "Delivered")
                        }
                    }) {
                        Text("Approve & Deliver")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }

                    Button(action: {
                        Task {
                            _ = await service.updateOrderStatus(orderId: order.id, newStatus: "Rejected")
                        }
                    }) {
                        Text("Reject")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.15))
                            .foregroundColor(.red)
                            .cornerRadius(8)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 5, x: 0, y: 2)
    }
}

struct StatusBadge: View {
    let status: String

    var color: Color {
        let s = status.lowercased()
        if s.contains("deliver") { return .green }
        if s.contains("pending") { return .orange }
        if s.contains("reject") { return .red }
        return .blue
    }

    var body: some View {
        Text(status)
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .cornerRadius(12)
    }
}
