import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var showingNewSpendingSheet = false
    @State private var showingSettingsSheet = false
    @State private var items: [SpendingItem] = []
    
    var body: some View {
        ZStack{
            Color(UIColor.systemGray6)
                            .edgesIgnoringSafeArea(.all)
            VStack {
                HomeView()
                SpendingList(items: $items)
                CustomTabBar(
                    showingNewSpendingSheet: $showingNewSpendingSheet,
                    showingSettingsSheet: $showingSettingsSheet
                )
            }
            .accentColor(.blue)
            .sheet(isPresented: $showingNewSpendingSheet) {
                NewSpendingPopUpView(items: $items)
            }
            .sheet(isPresented: $showingSettingsSheet) {
                SettingsPopUpView()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
