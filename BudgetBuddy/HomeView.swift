import SwiftUI

struct HomeView: View {
    let items: [SpendingItem]
    @Binding var selectedCategory: SpendingItem.Label
    @Binding var spendingLimit: Float
    
    var body: some View {
        let totalAmount = items.reduce(0) { $0 + $1.amount }
        let todayAmount = items.filter { Calendar.current.isDateInToday($0.timeAdded) }.reduce(0) { $0 + $1.amount }
        let weeklySpending = calculateWeeklySpending(for: selectedCategory, in: items)
        let scheduledAmount = spendingLimit + weeklySpending

        VStack(spacing: 20) {
            HStack(spacing: 15) {
                DashboardItemView(iconName: "calendar.circle.fill", iconColor: .blue, title: "Today", count: String(format: "%.2f", todayAmount))
                DashboardItemView(iconName: "calendar.badge.clock", iconColor: .red, title: "Scheduled", count: String(format: "%.2f", scheduledAmount))
            }
            HStack(spacing: 15) {
                DashboardItemView(iconName: "tray.circle.fill", iconColor: .black, title: "All", count: String(format: "%.2f", totalAmount))
                DashboardItemView(iconName: "checkmark.circle.fill", iconColor: .gray, title: "Completed", count: "0")
            }
        }
        .padding(.horizontal, 40)
        .padding(.top, 24)
    }

    private func calculateWeeklySpending(for category: SpendingItem.Label, in items: [SpendingItem]) -> Float {
        let currentWeek = Calendar.current.component(.weekOfYear, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        
        return items.filter { item in
            let itemWeek = Calendar.current.component(.weekOfYear, from: item.timeAdded)
            let itemYear = Calendar.current.component(.year, from: item.timeAdded)
            return item.label == category && itemWeek == currentWeek && itemYear == currentYear
        }.reduce(0) { $0 + $1.amount }
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
                    .font(.title)
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
