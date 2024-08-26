import SwiftUI

struct SpendingList: View {
    @Binding var items: [SpendingItem]
    
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
                        }
                    }
                }
            }
            .background(Color(UIColor.systemGray6))
            .scrollContentBackground(.hidden)
            .navigationBarTitle("Items List")
        }
        .background(Color(UIColor.systemGray6))
    }
}

struct SpendingItem: Identifiable {
    let id = UUID()
    let name: String
    let timeAdded: Date
}
