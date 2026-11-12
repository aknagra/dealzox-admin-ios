import Foundation

public struct Lead: Identifiable, Codable, Sendable {
    public let id: Int
    public let name: String?
    public let phone: String?
    public let status: String?
    public let createdAt: String?
    public let productId: String?
    public let productName: String?
    public let price: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case phone
        case status
        case createdAt = "created_at"
        case productId = "product_id"
        case productName = "product_name"
        case price
    }
}
