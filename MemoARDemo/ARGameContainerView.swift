//
//  ARGameContainerView.swift
//  Lostandfound
//
//  Created by Akmal Hakim on 03/05/25.
//

import SwiftUI

struct ARGameContainerView: View {
    @EnvironmentObject var dataManager: GameDataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var gameScore: Int = 0
    @State private var showingResults = false
    
    var body: some View {
        ZStack {
            ARViewControllerRepresentable(score: $gameScore, gameCompleted: {
                // This closure is called when the game is completed
                showingResults = true
                dataManager.saveGameResult(score: gameScore)
            })
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding()
                    
                    Spacer()
                }
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .alert(isPresented: $showingResults) {
            Alert(
                title: Text("Game Over"),
                message: Text("Your score: \(gameScore)"),
                dismissButton: .default(Text("Return to Menu")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}
