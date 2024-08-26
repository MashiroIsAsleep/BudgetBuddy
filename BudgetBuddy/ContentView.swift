import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var showingNewSpendingSheet = false
    @State private var showingSettingsSheet = false
    @State private var items: [SpendingItem] = [] {
        didSet {
            saveItems()
        }
    }
    @State private var highestItemNumber = 0

    var body: some View {
        ZStack {
            Color(UIColor.systemGray6)
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center, spacing: 16) {
                HomeView(items: items)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                SpendingList(items: $items)
                    .frame(maxWidth: 400, alignment: .center)
                
                CustomTabBar(
                    showingNewSpendingSheet: $showingNewSpendingSheet,
                    showingSettingsSheet: $showingSettingsSheet
                )
                .frame(maxWidth: 420, alignment: .center)
            }
            .padding(.horizontal, 16)
            .accentColor(.blue)
            .sheet(isPresented: $showingNewSpendingSheet) {
                NewSpendingPopUpView(items: $items, highestItemNumber: $highestItemNumber, saveItems: saveItems)
            }
            .sheet(isPresented: $showingSettingsSheet) {
                SettingsPopUpView()
            }
        }
        .onAppear {
            loadItems()
            updateHighestItemNumber()
        }
    }
    
    private func updateHighestItemNumber() {
        let itemNumbers = items.compactMap { item in
            Int(item.name.split(separator: " ").last ?? "")
        }
        highestItemNumber = itemNumbers.max() ?? 0
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




#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
