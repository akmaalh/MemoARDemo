//
//  HistoryView.swift
//  Lostandfound
//
//  Created by Akmal Hakim on 03/05/25.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var dataManager: GameDataManager
    
    var body: some View {
        NavigationView {
            List {
                if dataManager.gameHistory.isEmpty {
                    Text("No game history yet")
                        .foregroundColor(.gray)
                        .italic()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ForEach(dataManager.gameHistory.sorted(by: { $0.date > $1.date })) { record in
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text(record.userName)
                                    .font(.headline)
                                Spacer()
                                Text("Score: \(record.score)")
                                    .font(.headline)
                                    .foregroundColor(.green)
                            }
                            
                            Text(formatDate(record.date))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .navigationTitle("Game History")
            .navigationBarItems(trailing: Button("Clear") {
                dataManager.clearHistory()
            })
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
