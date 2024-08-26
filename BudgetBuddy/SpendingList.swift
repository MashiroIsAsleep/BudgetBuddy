import SwiftUI
import Foundation

struct SpendingList: View {
    @Binding var items: [SpendingItem] {
        didSet {
            saveItems()
        }
    }
    @State private var selectedSpendingItem: SpendingItem? = nil
    
    var groupedItems: [String: [SpendingItem]] {
        Dictionary(grouping: items) { item in
            if Calendar.current.isDateInToday(item.timeAdded) {
                return "Today"
            } else if Calendar.current.isDate(item.timeAdded, equalTo: Date(), toGranularity: .weekOfYear) {
                return "This Week"
            } else if Calendar.current.isDate(item.timeAdded, equalTo: Date(), toGranularity: .month) {
                return "This Month"
            } else {
                return "Earlier"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(groupedItems.keys.sorted()), id: \.self) { key in
                    Section(header: Text(key)) {
                        ForEach(groupedItems[key]!.sorted(by: { $0.timeAdded > $1.timeAdded })) { item in
                            HStack {
                                Text("\(item.timeAdded, formatter: itemFormatter)")
                                Spacer()
                                Text(String(format: "%.2f", item.amount) + "$")
                                Spacer()
                                Text(item.label.rawValue.capitalized)
                            }
                            .onTapGesture {
                                selectedSpendingItem = item
                            }
                        }
                        .onDelete { indexSet in
                            deleteItems(at: indexSet, in: key)
                        }
                    }
                }
            }
            .background(Color(UIColor.systemGray6))
            .scrollContentBackground(.hidden)
            .navigationBarTitle("Items List")
            .sheet(item: $selectedSpendingItem) { item in
                SpendingItemDetailView(spendingItem: item)
            }
        }
        .background(Color(UIColor.systemGray6))
        .onAppear {
            loadItems()
        }
    }
    
    private func deleteItems(at offsets: IndexSet, in section: String) {
        if let itemsInSection = groupedItems[section] {
            let sortedItems = itemsInSection.sorted(by: { $0.timeAdded > $1.timeAdded })
            offsets.forEach { index in
                let itemToRemove = sortedItems[index]
                items.removeAll { $0.id == itemToRemove.id }
            }
        }
    }
    
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: "spendingItems")
        }
    }

    private func loadItems() {
        if let savedItems = UserDefaults.standard.object(forKey: "spendingItems") as? Data {
            if let decodedItems = try? JSONDecoder().decode([SpendingItem].self, from: savedItems) {
                items = decodedItems
            }
        }
    }
}

// DateFormatter for displaying date and time
private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, HH:mm"
    return formatter
}()




struct SpendingItemDetailView: View {
    let spendingItem: SpendingItem

    var body: some View {
        VStack {
            Text(spendingItem.name)
                .font(.largeTitle)
                .padding()
            
            Text(String(format: "%.2f", spendingItem.amount))
                .font(.title2)
                .padding()

            Text(spendingItem.label.rawValue.capitalized)
                .font(.headline)
                .padding()

            Text(spendingItem.comment)
                .padding()

            Spacer()
        }
        .padding()
        .presentationDetents([.medium, .large]) // Optional: Allows you to control the size of the sheet
        .presentationDragIndicator(.visible) // Optional: Adds a drag indicator
    }
}






struct SpendingItem: Identifiable, Codable {
    let id: UUID
    let amount: Float
    let label: Label
    let comment: String
    let timeAdded: Date
    let name: String
    
    enum Label: String, Codable, CaseIterable {
        case a, b, c, income
    }
    
    // Custom CodingKeys to handle encoding/decoding
    enum CodingKeys: String, CodingKey {
        case id, amount, label, comment, timeAdded, name
    }
    
    // Custom init for decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.amount = try container.decode(Float.self, forKey: .amount)
        self.label = try container.decode(Label.self, forKey: .label)
        self.comment = try container.decode(String.self, forKey: .comment)
        self.timeAdded = try container.decode(Date.self, forKey: .timeAdded)
        self.name = try container.decode(String.self, forKey: .name)
    }
    
    // Default init
    init(id: UUID = UUID(), amount: Float, label: Label, comment: String, timeAdded: Date, name: String) {
        self.id = id
        self.amount = amount
        self.label = label
        self.comment = comment
        self.timeAdded = timeAdded
        self.name = name
    }
}




