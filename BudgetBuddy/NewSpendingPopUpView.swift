import SwiftUI

struct NewSpendingPopUpView: View {
    @Binding var items: [SpendingItem]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Add New Goal")
                .font(.headline)
                .padding()
            
            Button(action: {
                addSpendingItem()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Add Goal")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
    
    func addSpendingItem() {
        let newSpendingItem = SpendingItem(name: "Goal \(items.count + 1)", timeAdded: Date())
        items.append(newSpendingItem)
    }
}
