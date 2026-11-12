import Foundation

public struct SiteSettings: Codable, Sendable {
    public let id: Int
    public var storeOpen: Bool
    public var bannerEnabled: Bool?
    public var bannerText: String?
    public var upiId: String?
    public var telegramUrl: String?
    public var instagramUrl: String?
    public var adminPin: String?

    enum CodingKeys: String, CodingKey {
        case id
        case storeOpen = "store_open"
        case bannerEnabled = "banner_enabled"
        case bannerText = "banner_text"
        case upiId = "upi_id"
        case telegramUrl = "telegram_url"
        case instagramUrl = "instagram_url"
        case adminPin = "admin_pin"
    }
}
