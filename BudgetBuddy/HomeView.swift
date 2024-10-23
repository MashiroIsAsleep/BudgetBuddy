import SwiftUI
import Charts

struct HomeView: View {
    let items: [SpendingItem]
    @Binding var selectedCategory: SpendingItem.Label
    @Binding var spendingLimit: Float
    @State private var emailAddresses: [String] = UserDefaults.standard.stringArray(forKey: "emailAddresses") ?? [""] // Load email addresses from UserDefaults
    @State private var isEmailAlertPresented = false // State variable to control the email alert
    
    @State private var expandedBox: Int? = nil // Tracks which box is expanded (if any)

    // Computed property to calculate scheduledAmount
    private var scheduledAmount: Float {
        let weeklySpending = calculateWeeklySpending(for: selectedCategory, in: items)
        let result = spendingLimit + weeklySpending
        print("Calculated Scheduled Amount: \(result)") // Debug print to verify the calculation
        return result
    }

    var body: some View {
        let totalIncome = items.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
        let totalSpending = items.filter { $0.amount < 0 }.reduce(0) { $0 + $1.amount }
        let todayAmount = items.filter { Calendar.current.isDateInToday($0.timeAdded) }.reduce(0) { $0 + $1.amount }

        ZStack {
            VStack(spacing: 20) {
                HStack(spacing: 15) {
                    DashboardItemView(iconName: "chart.bar.fill", iconColor: .blue, title: "Today", count: formatNumber(todayAmount), index: 0, expandedBox: $expandedBox, items: items)
                    DashboardItemView(iconName: scheduledIconName(scheduledAmount: scheduledAmount), iconColor: scheduledIconColor(scheduledAmount: scheduledAmount), title: "Remaining Budget", count: formatNumber(scheduledAmount), index: 1, expandedBox: $expandedBox, items: items)
                }
                HStack(spacing: 15) {
                    DashboardItemView(iconName: "arrowshape.up.circle.fill", iconColor: .green, title: "All Time Income", count: formatNumber(totalIncome), index: 2, expandedBox: $expandedBox, items: items)
                    DashboardItemView(iconName: "arrowshape.down.circle.fill", iconColor: .red, title: "All Time Spending", count: formatNumber(abs(totalSpending)), index: 3, expandedBox: $expandedBox, items: items)
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 24)
            .blur(radius: expandedBox != nil ? 10 : 0) // Blur effect when a box is expanded

            // Show expanded content as an overlay
            if let selectedBox = expandedBox {
                if selectedBox == 0 {
                    // Display a compact list of today's transactions
                    ExpandedTodayListView(items: items)
                        .transition(.move(edge: .bottom)) // Transition effect
                        .zIndex(1)
                        .onTapGesture {
                            withAnimation {
                                expandedBox = nil // Collapse on tap
                            }
                        }
                } else if selectedBox == 2 || selectedBox == 3 {
                    // Display a bar chart of 7-day income or spending
                    ExpandedBarChartView(items: items, isIncome: selectedBox == 2)
                        .transition(.move(edge: .bottom)) // Transition effect
                        .zIndex(1)
                        .onTapGesture {
                            withAnimation {
                                expandedBox = nil // Collapse on tap
                            }
                        }
                }
            }
        }
        .onChange(of: scheduledAmount) {
            if scheduledAmount < 0 {
                isEmailAlertPresented = true
                print("Email alert should be presented with final scheduled amount: \(scheduledAmount)")
            }
        }
        .alert(isPresented: $isEmailAlertPresented) {
            Alert(
                title: Text("Budget Exceeded"),
                message: Text("Your remaining budget is negative. Do you want to notify your friends via email?"),
                primaryButton: .default(Text("Send Email"), action: {
                    sendEmailNotification(scheduledAmount: scheduledAmount)
                    print("Attempting to send email with scheduled amount: \(scheduledAmount)") // Debug print to confirm email sending is attempted
                }),
                secondaryButton: .cancel()
            )
        }
    }
    
    // Helper functions for managing the view
    private func scheduledIconName(scheduledAmount: Float) -> String {
        return scheduledAmount >= 0 ? "creditcard.fill" : "creditcard.trianglebadge.exclamationmark.fill"
    }

    private func scheduledIconColor(scheduledAmount: Float) -> Color {
        return scheduledAmount >= 0 ? Color.gray : Color.yellow
    }

    private func formatNumber(_ value: Float) -> String {
        if abs(value) >= 500_000 {
            return String(format: "%.3fM", value / 1_000_000)
        } else if abs(value) >= 500 {
            return String(format: "%.2fK", value / 1_000)
        } else {
            return String(format: "%.1f$", value)
        }
    }

    private func calculateWeeklySpending(for category: SpendingItem.Label, in items: [SpendingItem]) -> Float {
        guard let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else {
            return 0
        }
        
        return items.filter { item in
            return item.label == category && item.timeAdded >= startOfWeek
        }.reduce(0) { $0 + $1.amount }
    }

    //*Customize the email body based on WHICH budget was broken. (optional)
    private func sendEmailNotification(scheduledAmount: Float) {
        let subject = "I have broke my promise and exceeded my budget :("
        let body = "My remaining budget is negative: \(formatNumber(scheduledAmount)). I have spent more than I was supposed to, and I deeply regret not sticking to the planned expenses. I understand the importance of staying within the limits and will make every effort to improve my spending habits moving forward."
        
        for email in emailAddresses where !email.isEmpty {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let viewController = scene.windows.first?.rootViewController {
                EmailSender.shared.sendEmail(
                    recipient: email,
                    subject: subject,
                    body: body,
                    from: viewController
                )
            }
        }
    }
}

struct ExpandedTodayListView: View {
    let items: [SpendingItem]
    
    var body: some View {
        VStack {
            Text("Transactions Today")
                .font(.headline)
                .padding()
            
            List {
                ForEach(items.filter { Calendar.current.isDateInToday($0.timeAdded) }) { item in
                    HStack {
                        Text(item.name)
                        Spacer()
                        Text(String(format: "%.2f", item.amount))
                    }
                }
            }
            .frame(height: 300) // Adjust height as needed
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding()
    }
}

struct ExpandedBarChartView: View {
    let items: [SpendingItem]
    let isIncome: Bool

    // Generate last 7 days' data
    var last7DaysData: [(String, Float)] {
        var data: [(String, Float)] = []
        let calendar = Calendar.current
        for dayOffset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date())!
            let totalForDay = items.filter {
                calendar.isDate($0.timeAdded, inSameDayAs: date) && (($0.amount > 0) == isIncome)
            }.reduce(0) { $0 + $1.amount }
            data.append((formattedDate(date), totalForDay))
        }
        return data.reversed() // Show in correct order
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter.string(from: date)
    }

    var body: some View {
        VStack {
            Text(isIncome ? "Income Over the Last 7 Days" : "Spending Over the Last 7 Days")
                .font(.headline)
                .padding()
            
            Chart(last7DaysData, id: \.0) { day, value in
                BarMark(
                    x: .value("Day", day),
                    y: .value("Total", value)
                )
                .foregroundStyle(isIncome ? .green : .red)
            }
            .frame(height: 300) // Adjust chart height as needed
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding()
    }
}

struct DashboardItemView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var iconName: String
    var iconColor: Color
    var title: String
    var count: String
    var index: Int // Add index to identify each box
    @Binding var expandedBox: Int? // Track which box is expanded
    var items: [SpendingItem] // Passing the items for use in the expanded views
    
    var body: some View {
        VStack {
            if expandedBox == index {
                // Expanded view handled in parent
            } else {
                // Normal box view
                VStack {
                    HStack {
                        Spacer().frame(width: 8)
                        Image(systemName: iconName)
                            .foregroundColor(iconColor)
                            .font(.title)
                        Spacer()
                        Text(count)
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color(UIColor.label))
                        Spacer().frame(width: 8)
                    }
                    Spacer().frame(height: 8)
                    HStack{
                        Spacer().frame(width: 10)
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
                .frame(width: 170, height: 80)
                .background(
                    colorScheme == .dark
                        ? Color.black.opacity(0.7)
                        : Color.white
                )
                .cornerRadius(16)
                .onTapGesture {
                    withAnimation {
                        expandedBox = index // Expand the clicked box
                    }
                }
            }
        }
    }
}
