//
//  HistoryView.swift
//  Lostandfound
//
//  Created by Akmal Hakim on 03/05/25.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var dataManager: GameDataManager
    @Environment(\.presentationMode) var presentationMode // For potential custom back button or dismissal

    // Consistent colors from HomeScreen/GameView
    let listBackgroundColor = Color(red: 0.98, green: 0.97, blue: 0.93) // Light cream
    let primaryTextColor = Color(red: 0.2, green: 0.2, blue: 0.2)         // Dark text for main info
    let secondaryTextColor = Color(red: 0.45, green: 0.45, blue: 0.45)     // Medium gray for secondary info
    let scoreColor = Color(red: 0.2, green: 0.6, blue: 0.35)              // Greenish for score
    let themeColor = Color(red: 0.1, green: 0.4, blue: 0.7)               // Bluish for theme
    let clearButtonColor = Color(red: 0.95, green: 0.69, blue: 0.26)     // Orange (like other main buttons)
    let clearButtonTextColor = Color(red: 0.4, green: 0.2, blue: 0.1)    // Dark Brown
    let navigationBarColor = Color(red: 0.96, green: 0.95, blue: 0.91) // Slightly darker cream for nav bar
    
    init() {
        // Customize Navigation Bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(navigationBarColor)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(primaryTextColor)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(primaryTextColor)]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        // For back button color, if needed
        UINavigationBar.appearance().tintColor = UIColor(clearButtonColor) 
    }

    var body: some View {
        // NavigationView is likely already present if this view is pushed. 
        // If presented modally or as root of a tab, it might be needed.
        // For now, assuming it's pushed onto an existing NavigationView.
        ZStack {
            listBackgroundColor.edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading, spacing: 16) {
                Text("Riwayat Permainan") // Indonesian title
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(primaryTextColor)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                List {
                    if dataManager.gameHistory.isEmpty {
                        Text("Belum ada riwayat permainan") // Indonesian text
                            .font(.system(size: 20))
                            .foregroundColor(secondaryTextColor)
                            .italic()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .listRowBackground(listBackgroundColor)
                    } else {
                        ForEach(dataManager.gameHistory.sorted(by: { $0.date > $1.date })) { record in
                            VStack(alignment: .leading, spacing: 6) { // Slightly increased spacing
                                HStack {
                                    Text(record.userName)
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(primaryTextColor)
                                    Spacer()
                                    Text("Skor: \(record.score)") // Indonesian text
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(scoreColor)
                                }
                                
                                HStack {
                                    Text(getIndonesianThemeName(record.theme))
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(themeColor)
                                    Spacer()
                                    Text(formatDate(record.date))
                                        .font(.system(size: 18))
                                        .foregroundColor(secondaryTextColor)
                                }
                            }
                            .padding(.vertical, 8) // Increased padding
                            .listRowBackground(listBackgroundColor)
                        }
                    }
                }
                .listStyle(PlainListStyle()) // Use PlainListStyle for full background color effect
                .background(listBackgroundColor) // Ensure background color for the List itself
                // .navigationTitle("Riwayat Permainan"). // Indonesian text
                .toolbar { // Preferred way to add bar items in newer SwiftUI
                    // ToolbarItem(placement: .navigationBarTrailing) {
                    //     Button {
                    //         dataManager.clearHistory()
                    //     } label: {
                    //         Text("Hapus") // Indonesian text
                    //             .font(.system(size: 20, weight: .bold))
                    //             .padding(.horizontal, 8)
                    //             .padding(.vertical, 4)
                    //             .foregroundColor(clearButtonTextColor)
                    //             .background(clearButtonColor)
                    //             .cornerRadius(8)
                    //     }
                    //     .disabled(dataManager.gameHistory.isEmpty)
                    // }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID") // Set Indonesian locale
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
        
    private func getIndonesianThemeName(_ theme: String) -> String {
        switch theme.lowercased() {
        case "kitchen":
            return "Dapur"
        case "bathroom":
            return "Kamar Mandi"
        case "garage":
            return "Garasi"
        default:
            return theme
        }
    }
}

// MARK: - Preview Provider
struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .environmentObject(GameDataManager())
    }
}
