import SwiftUI

struct NewSpendingPopUpView: View {
    @Binding var items: [SpendingItem]
    @Binding var highestItemNumber: Int
    @Environment(\.presentationMode) var presentationMode
    
    @State private var amount: String = ""
    @State private var selectedLabel: SpendingItem.Label = .income // Default to income
    @State private var comment: String = ""
    @State private var isIncome: Bool = true // Default to Income
    
    var saveItems: () -> Void
    
    var body: some View {
        VStack {
            Text("Add New Goal")
                .font(.headline)
                .padding()
            
            HStack {
                VStack {
                    Picker("Type", selection: $isIncome) {
                        Text("Income").tag(true)
                        Text("Spending").tag(false)
                    }
                    .pickerStyle(WheelPickerStyle())
                }
                .frame(width: 120)
                
                TextField("Enter amount", text: $amount)
                    .keyboardType(.decimalPad)
                    .padding()
                    .border(Color.gray)
            }
            .padding()
            
            if !isIncome {
                Picker("Select Label", selection: $selectedLabel) {
                    ForEach(SpendingItem.Label.allCases.filter { $0 != .income }, id: \.self) { label in
                        Text(label.rawValue.capitalized).tag(label)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
            }
            
            TextField("Enter comment", text: $comment)
                .padding()
                .border(Color.gray)
            
            Button(action: {
                if let amountValue = Float(amount) {
                    let finalAmount = isIncome ? amountValue : -amountValue
                    highestItemNumber += 1
                    let newSpendingItem = SpendingItem(
                        amount: finalAmount,
                        label: selectedLabel,
                        comment: comment,
                        timeAdded: Date(),
                        name: "Goal \(highestItemNumber)"
                    )
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
        .onChange(of: isIncome) { oldValue, newValue in
            if newValue {
                selectedLabel = .income // Automatically set label to income when Income is selected
            }
        }
    }
}
