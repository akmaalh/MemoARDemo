//
//  GameSelectionView.swift
//  Lostandfound
//
//  Created by Akmal Hakim on 03/05/25.
//

import SwiftUI

struct GameSelectionView: View {
    @EnvironmentObject var dataManager: GameDataManager
    @State private var navigateToGame = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "gamecontroller.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100)
                    .foregroundColor(.green)
                    .padding()
                
                Text("Environment: Kitchen")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Find the unusual objects in the kitchen!")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    navigateToGame = true
                }) {
                    Text("Start Game")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(minWidth: 200)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .padding(.bottom, 50)
                
                NavigationLink(
                    destination: ARGameContainerView(),
                    isActive: $navigateToGame
                ) {
                    EmptyView()
                }
            }
            .navigationTitle("Kitchen Hunt")
        }
    }
}
