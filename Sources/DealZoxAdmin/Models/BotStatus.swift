import Foundation

public struct BotStatus: Codable, Sendable {
    public let ok: Bool
    public let service: String?
    public let version: String?
    public let hasToken: Bool?
    public let hasPhoneNumberId: Bool?
    public let hasSupabase: Bool?
    public let ocrEnabled: Bool?
    public let humanPaused: Int?
    public let forwardedOrders: Int?
    public let uptimeSeconds: Int?
}
