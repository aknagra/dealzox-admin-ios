import SwiftUI

public struct BotControlView: View {
    @ObservedObject var bot = BotService.shared

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                Section(header: Text("WhatsApp Cloud Bot Status")) {
                    HStack {
                        Text("Service Status")
                        Spacer()
                        HStack(spacing: 6) {
                            Circle()
                                .fill(bot.isOnline ? Color.green : Color.red)
                                .frame(width: 10, height: 10)
                            Text(bot.isOnline ? "Online & Live" : "Offline")
                                .fontWeight(.semibold)
                                .foregroundColor(bot.isOnline ? .green : .red)
                        }
                    }

                    if let status = bot.botStatus {
                        HStack {
                            Text("Service Name")
                            Spacer()
                            Text(status.service ?? "Cloud Webhook")
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Text("Version")
                            Spacer()
                            Text(status.version ?? "1.0")
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Text("Forwarded Orders")
                            Spacer()
                            Text("\(status.forwardedOrders ?? 0)")
                                .foregroundColor(.blue)
                                .fontWeight(.bold)
                        }

                        if let uptime = status.uptimeSeconds {
                            HStack {
                                Text("Uptime")
                                Spacer()
                                Text("\(uptime / 3600) hrs \((uptime % 3600) / 60) mins")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                Section(header: Text("Actions")) {
                    Button(action: {
                        Task {
                            await bot.checkHealth()
                        }
                    }) {
                        HStack {
                            Label("Ping & Refresh Bot", systemImage: "arrow.clockwise")
                            Spacer()
                            if bot.checking {
                                ProgressView()
                            }
                        }
                    }

                    Link(destination: URL(string: "https://wa.dealzox.in/health")!) {
                        Label("Open Webhook Endpoint", systemImage: "safari")
                    }
                }

                Section(footer: Text("Cloud API bot customers ko automated updates aur product delivery send karta hai jab aap order approve karte hain.")) {}
            }
            .navigationTitle("WhatsApp Bot")
            .task {
                await bot.checkHealth()
            }
        }
    }
}
