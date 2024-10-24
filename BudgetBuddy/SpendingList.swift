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
    
    var sortedSectionKeys: [String] {
        let sectionOrder = ["Today", "This Week", "This Month", "Earlier"]
        return sectionOrder.filter { groupedItems[$0] != nil }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sortedSectionKeys, id: \.self) { key in
                    Section(header: Text(key)) {
                        ForEach(groupedItems[key]!.sorted(by: { $0.timeAdded > $1.timeAdded })) { item in
                            HStack {
                                Text("\(item.timeAdded, formatter: itemFormatter)")
                                    .frame(maxWidth: 70, alignment: .leading)
                                
                                Text(item.label.rawValue.capitalized)
                                    .bold()
                                    .frame(maxWidth: .infinity)
                                
                                Text(String(format: "%.2f", item.amount) + "$")
                                    .padding(.leading, 8)
                                    .padding(.trailing, 8)
                                    .padding(.top, 4)
                                    .padding(.bottom, 4)
                                    .background(item.amount > 0 ? Color.green.opacity(0.7) : Color.red.opacity(0.7))
                                    .cornerRadius(8)
                                    .multilineTextAlignment(.trailing)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
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
        VStack(alignment: .leading, spacing: 16) {
            // Title: Spending/Earning Name
            HStack {
                Image(systemName: spendingItem.amount > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(spendingItem.amount > 0 ? .green : .red)
                Text(spendingItem.name)
                    .font(.largeTitle)
                    .bold()
                    .padding(.leading, 8)
            }
            .padding(.top)
            
            Divider()
            
            // Amount Section
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.green)
                Text("Amount:")
                    .font(.title3)
                    .bold()
                Spacer()
                Text(String(format: "%.2f$", spendingItem.amount))
                    .font(.title3)
                    .foregroundColor(spendingItem.amount > 0 ? .green : .red)
            }
            .padding(.vertical, 8)
            
            Divider()
            
            // Category Label Section
            HStack {
                Image(systemName: "tag.fill")
                    .foregroundColor(.blue)
                Text("Category:")
                    .font(.title3)
                    .bold()
                Spacer()
                Text(spendingItem.label.rawValue.capitalized)
                    .font(.title3)
            }
            .padding(.vertical, 8)
            
            Divider()
            
            // Comment Section
            if !spendingItem.comment.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "text.bubble.fill")
                            .foregroundColor(.gray)
                        Text("Comment:")
                            .font(.title3)
                            .bold()
                    }
                    Text(spendingItem.comment)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.leading, 30) // Add a little indentation for comments
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 10)
        .presentationDetents([.medium, .large]) // Allows you to control the size of the sheet
        .presentationDragIndicator(.visible) // Adds a drag indicator
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
    init(id: UUID = UUID(), amount: Float, label: Label, comment: String, timeAdded: Date) {
        self.id = id
        self.amount = amount
        self.label = label
        self.comment = comment
        self.timeAdded = timeAdded
        
        // Generate a name based on the amount (spending/earning) and timeAdded
        let timeString = DateFormatter.localizedString(from: timeAdded, dateStyle: .medium, timeStyle: .short)
        if amount > 0 {
            self.name = "Earning at \(timeString)"
        } else {
            self.name = "Spending at \(timeString)"
        }
    }
}





