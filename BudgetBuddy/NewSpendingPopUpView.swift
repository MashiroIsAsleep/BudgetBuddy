import SwiftUI

struct NewSpendingPopUpView: View {
    @Binding var items: [SpendingItem]
    @Binding var highestItemNumber: Int
    @Environment(\.presentationMode) var presentationMode
    
    @State private var amount: String = ""
    @State private var selectedLabel: SpendingItem.Label = .income // Default to income
    @State private var comment: String = ""
    @State private var isIncome: Bool = true // Default to Income
    @State private var randomQuote: String = ""
    
    var saveItems: () -> Void
    
    let quotes = [
        "Watch your spending, or your wallet will shrink faster than you think!",
        "A penny saved is a penny earned.",
        "Spending without limits is a one-way ticket to debt.",
        "Every little purchase adds up – be mindful!",
        "Savings today lead to peace of mind tomorrow.",
        "Don’t let small purchases turn into big regrets.",
        "Frugality is not about saving money but having control over it.",
        "If you buy things you don’t need, you’ll soon sell things you do.",
        "A budget is telling your money where to go instead of wondering where it went.",
        "The more you save, the more opportunities you have.",
        "Money looks better in the bank than on your feet.",
        "Small leaks can sink big ships – monitor your spending.",
        "Financial discipline today ensures a secure tomorrow.",
        "Impulse spending is a sure path to regret.",
        "Keep track of your expenses – it’s easy to lose control.",
        "Every dollar you save brings you closer to financial freedom.",
        "Wise spending now means fewer financial worries later.",
        "Think twice before making non-essential purchases.",
        "The cost of financial freedom is discipline in spending.",
        "Don’t let your money control you – control your money."
    ]
    
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
                    Text(randomQuote)
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding()
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .background(Color(.white))
                        .cornerRadius(15)
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
        .onAppear {
            randomQuote = quotes.randomElement() ?? ""
        }
    }
}
