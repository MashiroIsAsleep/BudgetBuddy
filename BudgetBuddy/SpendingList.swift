import SwiftUI

struct SpendingList: View {
    @Binding var items: [SpendingItem]
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
                            Text(item.name)
                                .onTapGesture {
                                    selectedSpendingItem = item
                                }
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
    }
}

struct SpendingItemDetailView: View {
    let spendingItem: SpendingItem

    var body: some View {
        VStack {
            Text(spendingItem.name)
                .font(.largeTitle)
                .padding()

            // Add more details here about the SpendingItem
            Spacer() // To push the content to the top
        }
        .padding()
        .presentationDetents([.medium, .large]) // Optional: Allows you to control the size of the sheet
        .presentationDragIndicator(.visible) // Optional: Adds a drag indicator
    }
}

struct SpendingItem: Identifiable {
    let id = UUID()
    let name: String
    let timeAdded: Date
}
