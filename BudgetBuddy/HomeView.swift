import SwiftUI

struct HomeView: View {
    let items: [SpendingItem]
    @Binding var selectedCategory: SpendingItem.Label
    @Binding var spendingLimit: Float
    
    var body: some View {
        let totalIncome = items.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
        let totalSpending = items.filter { $0.amount < 0 }.reduce(0) { $0 + $1.amount }
        let todayAmount = items.filter { Calendar.current.isDateInToday($0.timeAdded) }.reduce(0) { $0 + $1.amount }
        let weeklySpending = calculateWeeklySpending(for: selectedCategory, in: items)
        let scheduledAmount = spendingLimit + weeklySpending
        
        // Choose icon based on the value of scheduledAmount
        let scheduledIconName = scheduledAmount >= 0 ? "creditcard.fill" : "creditcard.trianglebadge.exclamationmark.fill"
        let scheduledIconColor = scheduledAmount >= 0 ? Color.gray : Color.yellow

        VStack(spacing: 20) {
            HStack(spacing: 15) {
                DashboardItemView(iconName: "chart.bar.fill", iconColor: .blue, title: "Today", count: formatNumber(todayAmount))
                DashboardItemView(iconName: scheduledIconName, iconColor: scheduledIconColor, title: "Remaining Budget", count: formatNumber(scheduledAmount))
            }
            HStack(spacing: 15) {
                DashboardItemView(iconName: "arrowshape.up.circle.fill", iconColor: .green, title: "All Time Income", count: formatNumber(totalIncome))
                DashboardItemView(iconName: "arrowshape.down.circle.fill", iconColor: .red, title: "All Time Spending", count: formatNumber(abs(totalSpending)))
            }
        }
        .padding(.horizontal, 40)
        .padding(.top, 24)
    }

    private func calculateWeeklySpending(for category: SpendingItem.Label, in items: [SpendingItem]) -> Float {
        guard let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else {
            return 0
        }
        
        return items.filter { item in
            return item.label == category && item.timeAdded >= startOfWeek
        }.reduce(0) { $0 + $1.amount }
    }
    
    // Number formatting function
    private func formatNumber(_ value: Float) -> String {
        if abs(value) >= 500_000 {
            return String(format: "%.3fM", value / 1_000_000)
        } else if abs(value) >= 500 {
            return String(format: "%.2fK", value / 1_000)
        } else {
            return String(format: "%.1f$", value)
        }
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
