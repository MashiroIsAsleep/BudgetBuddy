import SwiftUI
import MessageUI // Required for MFMailComposeViewController

struct HomeView: View {
    let items: [SpendingItem]
    @Binding var selectedCategory: SpendingItem.Label
    @Binding var spendingLimit: Float
    @State private var emailAddresses: [String] = UserDefaults.standard.stringArray(forKey: "emailAddresses") ?? [""] // Load email addresses from UserDefaults
    @State private var isEmailAlertPresented = false // State variable to control the email alert

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

        VStack(spacing: 20) {
            HStack(spacing: 15) {
                DashboardItemView(iconName: "chart.bar.fill", iconColor: .blue, title: "Today", count: formatNumber(todayAmount))
                DashboardItemView(iconName: scheduledIconName(scheduledAmount: scheduledAmount), iconColor: scheduledIconColor(scheduledAmount: scheduledAmount), title: "Remaining Budget", count: formatNumber(scheduledAmount))
            }
            HStack(spacing: 15) {
                DashboardItemView(iconName: "arrowshape.up.circle.fill", iconColor: .green, title: "All Time Income", count: formatNumber(totalIncome))
                DashboardItemView(iconName: "arrowshape.down.circle.fill", iconColor: .red, title: "All Time Spending", count: formatNumber(abs(totalSpending)))
            }
        }
        .padding(.horizontal, 40)
        .padding(.top, 24)
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

    private func calculateWeeklySpending(for category: SpendingItem.Label, in items: [SpendingItem]) -> Float {
        guard let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else {
            return 0
        }
        
        return items.filter { item in
            return item.label == category && item.timeAdded >= startOfWeek
        }.reduce(0) { $0 + $1.amount }
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
    
    private func sendEmailNotification(scheduledAmount: Float) {
        let subject = "I have broke my promise and exceeded my budget :("
        let body = "My remaining budget is negative: \(formatNumber(scheduledAmount)). I have spent more than I was supposed to, and I deeply regret not sticking to the planned expenses. I understand the importance of staying within the limits and will make every effort to improve my spending habits moving forward."
        
        print("Scheduled Amount in Email: \(scheduledAmount)") // Debug print to check the value passed
        
        for email in emailAddresses where !email.isEmpty {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let viewController = scene.windows.first?.rootViewController {
                print("Attempting to present mail compose view controller") // Debug print before presenting email
                EmailSender.shared.sendEmail(
                    recipient: email,
                    subject: subject,
                    body: body,
                    from: viewController
                )
            }
        }
    }

    private func scheduledIconName(scheduledAmount: Float) -> String {
        return scheduledAmount >= 0 ? "creditcard.fill" : "creditcard.trianglebadge.exclamationmark.fill"
    }

    private func scheduledIconColor(scheduledAmount: Float) -> Color {
        return scheduledAmount >= 0 ? Color.gray : Color.yellow
    }
}




struct DashboardItemView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var iconName: String
    var iconColor: Color
    var title: String
    var count: String
    
    var body: some View {
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
    }
}
