import SwiftUI

struct SettingsPopUpView: View {
    @Environment(\.presentationMode) var presentationMode // For dismissing the view
    
    @State private var selectedCategory: SpendingItem.Label = .a // Default category
    @State private var spendingLimit: String = ""
    @State private var emailAddresses: [String] = [""] // Start with one empty email field
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Track Spending")
                    .font(.largeTitle)
                    .padding(.top, 20)
                
                // Category Picker
                Picker("Select Category", selection: $selectedCategory) {
                    ForEach(SpendingItem.Label.allCases.filter { $0 != .income }, id: \.self) { label in
                        Text(label.rawValue.capitalized).tag(label)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                // Spending Limit Input
                HStack {
                    Text("Weekly Limit:")
                    TextField("Enter amount", text: $spendingLimit)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
                
                // Email Addresses Input
                VStack(alignment: .leading) {
                    Text("Notification Emails:")
                    
                    ForEach($emailAddresses.indices, id: \.self) { index in
                        HStack {
                            TextField("Enter email address", text: $emailAddresses[index])
                                .keyboardType(.emailAddress)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            // Remove button
                            if emailAddresses.count > 1 {
                                Button(action: {
                                    emailAddresses.remove(at: index)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding(.vertical, 2)
                    }
                    
                    // Add button
                    Button(action: {
                        emailAddresses.append("")
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                            Text("Add Email")
                        }
                    }
                    .padding(.top, 10)
                }
                .padding()
                
                Spacer()
                
                // Save Button
                Button(action: {
                    saveSettings()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 20)
            }
            .padding()
            .navigationBarHidden(true) // Hide the default navigation bar
            .onAppear {
                loadSettings() // Load the settings when the view appears
            }
        }
    }
    
    // Save the settings to UserDefaults
    private func saveSettings() {
        UserDefaults.standard.set(selectedCategory.rawValue, forKey: "selectedCategory")
        UserDefaults.standard.set(spendingLimit, forKey: "spendingLimit")
        UserDefaults.standard.set(emailAddresses, forKey: "emailAddresses")
    }
    
    // Load the settings from UserDefaults
    private func loadSettings() {
        if let savedCategory = UserDefaults.standard.string(forKey: "selectedCategory"),
           let category = SpendingItem.Label(rawValue: savedCategory) {
            selectedCategory = category
        }
        
        spendingLimit = UserDefaults.standard.string(forKey: "spendingLimit") ?? ""
        
        if let savedEmails = UserDefaults.standard.stringArray(forKey: "emailAddresses") {
            emailAddresses = savedEmails.isEmpty ? [""] : savedEmails
        } else {
            emailAddresses = [""]
        }
    }
}
