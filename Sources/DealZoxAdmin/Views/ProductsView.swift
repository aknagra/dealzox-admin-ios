import SwiftUI

public struct ProductsView: View {
    @ObservedObject var service = SupabaseService.shared

    public init() {}

    public var body: some View {
        NavigationStack {
            List(service.products) { product in
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.title)
                            .font(.headline)

                        if let subtitle = product.subtitle {
                            Text(subtitle)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }

                        HStack(spacing: 8) {
                            if let deal = product.dealPrice {
                                Text("Deal: ₹\(deal)")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.green)
                            }
                            if let orig = product.originalPrice {
                                Text("₹\(orig)")
                                    .font(.caption)
                                    .strikethrough()
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(product.isActive ? "Active" : "Inactive")
                            .font(.caption2.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(product.isActive ? Color.green.opacity(0.15) : Color.gray.opacity(0.2))
                            .foregroundColor(product.isActive ? .green : .secondary)
                            .cornerRadius(8)

                        if let pid = product.productId {
                            Text(pid)
                                .font(.caption2)
                                .fontDesign(.monospaced)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Products Catalog")
            .refreshable {
                await service.fetchProducts()
            }
            .task {
                await service.fetchProducts()
            }
        }
    }
}
