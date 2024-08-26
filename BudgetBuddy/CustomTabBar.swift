import SwiftUI

struct CustomTabBar: View {
    @Binding var showingNewSpendingSheet: Bool
    @Binding var showingSettingsSheet: Bool
    
    var body: some View {
        ZStack {
            HStack {
                Spacer().frame(width: 10)
                Button(action: {
                    showingNewSpendingSheet = true
                }) {
                    HStack{
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.blue)
                        Spacer().frame(width: 10)
                        Text("New Spending")
                            .bold()
                    }
                }
                Spacer()
                Button(action: {
                    showingSettingsSheet = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.blue)
                }
                Spacer().frame(width: 10)
            }
            .padding()
            .frame(height: 50)
        }
    }
}
