import SwiftUI

public struct LeadsView: View {
    @ObservedObject var service = SupabaseService.shared
    @State private var searchText = ""

    public init() {}

    private var filteredLeads: [Lead] {
        if searchText.isEmpty {
            return service.leads
        }
        let q = searchText.lowercased()
        return service.leads.filter { lead in
            (lead.name?.lowercased().contains(q) ?? false) ||
            (lead.phone?.contains(q) ?? false) ||
            (lead.productName?.lowercased().contains(q) ?? false)
        }
    }

    public var body: some View {
        NavigationStack {
            Group {
                if filteredLeads.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.badge.questionmark")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("Koi lead nahi mila")
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(filteredLeads) { lead in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(lead.name ?? "Lead Customer")
                                        .font(.headline)
                                    Spacer()
                                    if let price = lead.price {
                                        Text("₹\(price)")
                                            .font(.subheadline.bold())
                                            .foregroundColor(.blue)
                                    }
                                }

                                if let product = lead.productName {
                                    Text(product)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }

                                if let phone = lead.phone {
                                    HStack {
                                        Label(phone, systemImage: "phone")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Link(destination: URL(string: "https://wa.me/91\(phone)")!) {
                                            Text("Message on WhatsApp")
                                                .font(.caption.bold())
                                                .foregroundColor(.green)
                                        }
                                    }
                                    .padding(.top, 2)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let lead = filteredLeads[index]
                                Task {
                                    _ = await service.deleteLead(leadId: lead.id)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Leads (\(filteredLeads.count))")
            .searchable(text: $searchText, prompt: "Search lead by name or phone")
            .refreshable {
                await service.fetchLeads()
            }
            .task {
                await service.fetchLeads()
            }
        }
    }
}
