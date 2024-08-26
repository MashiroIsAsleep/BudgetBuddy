import SwiftUI

struct HomeView: View {
    let items: [SpendingItem]
    
    var body: some View {
        let totalAmount = items.reduce(0) { $0 + $1.amount }
        let todayAmount = items.filter { Calendar.current.isDateInToday($0.timeAdded) }.reduce(0) { $0 + $1.amount }

        VStack(spacing: 20) {
            HStack(spacing: 15) {
                DashboardItemView(iconName: "calendar.circle.fill", iconColor: .blue, title: "Today", count: String(format: "%.2f", todayAmount))
                DashboardItemView(iconName: "calendar.badge.clock", iconColor: .red, title: "Scheduled", count: "0")
            }
            HStack(spacing: 15) {
                DashboardItemView(iconName: "tray.circle.fill", iconColor: .black, title: "All", count: String(format: "%.2f", totalAmount))
                DashboardItemView(iconName: "checkmark.circle.fill", iconColor: .gray, title: "Completed", count: "0")
            }
        }
        .padding(.horizontal, 40)
        .padding(.top, 24)
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
