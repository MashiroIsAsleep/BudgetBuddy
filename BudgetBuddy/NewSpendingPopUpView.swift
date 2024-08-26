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
        NavigationView {
            ZStack {
                Color(UIColor.systemGray6)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        VStack {
                            Picker("Type", selection: $isIncome) {
                                HStack {
                                    Image(systemName: "arrow.up.circle")
                                    Text("Gain")
                                }
                                .foregroundColor(.green)
                                .tag(true)
                                
                                HStack {
                                    Image(systemName: "arrow.down.circle")
                                    Text("Spend")
                                }
                                .foregroundColor(.red)
                                .tag(false)

                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 120, height: 100)
                        }
                        
                        TextField("Enter amount", text: $amount)
                            .frame(width: 180, height: 20)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color(.white))
                            .cornerRadius(15)
                    }
                    .padding()
                    
                    if !isIncome {
                        Picker("Select Label", selection: $selectedLabel) {
                            ForEach(SpendingItem.Label.allCases.filter { $0 != .income }, id: \.self) { label in
                                Text(label.rawValue.capitalized)
                                    .tag(label)
                                    .foregroundColor(.white)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                    }
                    
                    TextField("Enter comment", text: $comment)
                        .frame(maxWidth: 310, minHeight: 40)
                        .padding()
                        .background(Color(.white))
                        .cornerRadius(15)
                    
                    Spacer()
                }
                .padding()
                .onChange(of: isIncome) { oldValue, newValue in
                    if newValue {
                        selectedLabel = .income // Automatically set label to income when Income is selected
                    }
                }
            }
            .navigationBarTitle("New Spending", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Add") {
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
                }
            )
        }
    }
}
