import Foundation

@MainActor
public final class BotService: ObservableObject {
    public static let shared = BotService()

    private let botUrl = "https://wa.dealzox.in"

    @Published public var botStatus: BotStatus?
    @Published public var isOnline = false
    @Published public var checking = false

    public func checkHealth() async {
        checking = true
        do {
            let url = URL(string: "\(botUrl)/health")!
            let (data, response) = try await URLSession.shared.data(from: url)
            if let http = response as? HTTPURLResponse, http.statusCode == 200 {
                self.botStatus = try JSONDecoder().decode(BotStatus.self, from: data)
                self.isOnline = self.botStatus?.ok ?? false
            } else {
                self.isOnline = false
            }
        } catch {
            self.isOnline = false
        }
        checking = false
    }
}
