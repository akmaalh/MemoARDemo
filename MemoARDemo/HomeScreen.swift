//
//  HomeScreen.swift
//  
//
//  Created by Roy Nababan on 16/05/25.
//

import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject var dataManager: GameDataManager
    @State private var userName: String = "Nama" // Default name

    // Define colors based on the image
    let backgroundColor = Color(red: 0.98, green: 0.97, blue: 0.93) // Light cream
    let buttonColor = Color(red: 0.95, green: 0.69, blue: 0.26) // Orange
    let buttonTextColor = Color(red: 0.4, green: 0.2, blue: 0.1) // Dark Brown
    let textColor = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark text for greetings

    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    // Logo
                    Image(systemName: "brain.head.profile") // Placeholder for MemoAR logo
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .padding(.top, 50)
                        .foregroundColor(buttonColor)
                    
                    Text("MemoAR")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(textColor)

                    // Greeting
                    Text("Halo \(userName)!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                        .padding(.top, 20)

                    Text("Latih memorimu sekarang!")
                        .font(.title2)
                        .foregroundColor(textColor)
                        .padding(.bottom, 30)

                    // Navigation Buttons
//                    NavigationLink(destination: GameView(showHistory: false).environmentObject(dataManager)) {
//                        Text("Mulai Latihan")
//                            .modifier(MainButtonModifier(backgroundColor: buttonColor, textColor: buttonTextColor))
//                    }
//
//                    NavigationLink(destination: TutorialView().environmentObject(dataManager)) {
//                        Text("Lihat Video Tutorial")
//                            .modifier(MainButtonModifier(backgroundColor: buttonColor, textColor: buttonTextColor))
//                    }
//                    
//                    NavigationLink(destination: GameView(showHistory: true).environmentObject(dataManager)) {
//                        Text("Lihat Histori Nilai")
//                            .modifier(MainButtonModifier(backgroundColor: buttonColor, textColor: buttonTextColor))
//                    }

                    Spacer()
                }
                .padding(.horizontal)
            }
            .navigationBarHidden(true) // Hide navigation bar for a cleaner look
            .onAppear {
                if let currentUser = dataManager.currentUser {
                    userName = currentUser.name
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Recommended for fixing potential console warnings
    }
}

// Button Style Modifier
struct MainButtonModifier: ViewModifier {
    let backgroundColor: Color
    let textColor: Color

    func body(content: Content) -> some View {
        content
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(12)
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
            .environmentObject(GameDataManager()) // Ensure preview has the environment object
    }
} 
