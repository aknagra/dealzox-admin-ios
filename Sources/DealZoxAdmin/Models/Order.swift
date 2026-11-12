import Foundation

public struct Order: Identifiable, Codable, Sendable {
    public let id: Int
    public let orderId: String?
    public let createdAt: String?
    public let customerName: String?
    public let phone: String?
    public let utr: String?
    public let code: String?
    public var status: String
    public let productId: String?
    public let quantity: Int?
    public let totalPrice: Int?
    public let deliveredCodes: String?

    enum CodingKeys: String, CodingKey {
        case id
        case orderId = "order_id"
        case createdAt = "created_at"
        case customerName = "customer_name"
        case phone
        case utr
        case code
        case status
        case productId = "product_id"
        case quantity
        case totalPrice = "total_price"
        case deliveredCodes = "delivered_codes"
    }

    public var isPending: Bool {
        status.lowercased().contains("pending")
    }

    public var isDelivered: Bool {
        status.lowercased().contains("delivered")
    }

    public var isRejected: Bool {
        status.lowercased().contains("reject")
    }
}
