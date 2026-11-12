import Foundation

public struct Product: Identifiable, Codable, Sendable {
    public let id: Int
    public let title: String
    public let subtitle: String?
    public let originalPrice: Int?
    public let dealPrice: Int?
    public let imageUrl: String?
    public let redeemLink: String?
    public var isActive: Bool
    public let productId: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case subtitle
        case originalPrice = "original_price"
        case dealPrice = "deal_price"
        case imageUrl = "image_url"
        case redeemLink = "redeem_link"
        case isActive = "is_active"
        case productId = "product_id"
    }
}

public struct StockItem: Identifiable, Codable, Sendable {
    public let id: Int
    public let code: String
    public let productId: String?
    public let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case code
        case productId = "product_id"
        case createdAt = "created_at"
    }
}
