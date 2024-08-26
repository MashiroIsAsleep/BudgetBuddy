import SwiftUI

struct NewSpendingPopUpView: View {
    @Binding var items: [SpendingItem]
    @Binding var highestItemNumber: Int
    @Environment(\.presentationMode) var presentationMode
    
    @State private var amount: String = ""
    @State private var selectedLabel: SpendingItem.Label = .a
    @State private var comment: String = ""
    
    var saveItems: () -> Void
    
    var body: some View {
        VStack {
            Text("Add New Goal")
                .font(.headline)
                .padding()
            
            TextField("Enter amount", text: $amount)
                .keyboardType(.decimalPad)
                .padding()
                .border(Color.gray)
            
            Picker("Select Label", selection: $selectedLabel) {
                ForEach(SpendingItem.Label.allCases, id: \.self) { label in
                    Text(label.rawValue.capitalized).tag(label)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            TextField("Enter comment", text: $comment)
                .padding()
                .border(Color.gray)
            
            Button(action: {
                if let amountValue = Float(amount) {
                    highestItemNumber += 1
                    let newSpendingItem = SpendingItem(amount: amountValue, label: selectedLabel, comment: comment, timeAdded: Date(), name: "Goal \(highestItemNumber)")
                    items.append(newSpendingItem)
                    saveItems()
                }
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
}
